function [m,tensors] = leaf_setstrainpolarisation( m, varargin )
%[m,tensors] = leaf_setstrainpolarisation( m, ... )
%   Derive growth tensors for m from the residual strain.  Note that these
%   growth tensors will only be used to define growth if the
%   'usegrowthtensors' property has been set to true:
%
%       m = leaf_setproperty( m, 'useGrowthTensors', true );
%
%   Typically, you will not want growth to be also specified in the usual
%   way, and will want to turn that off.  In that case you should call:
%
%       m = leaf_setproperty( m, 'useGrowthTensors', true, 'useMorphogens', false );
%
%   If you set both properties to true, then growth will be the sum of both
%   effects: morphogens directly setting growth rates, and additional
%   growth derived from the residual strain.
%
%   The second output argument, if requested, will give the growth tensors
%   that were stored into m.
%
%   Options:
%       'mode': One of 'abs' (the default), 'tension', 'compression',
%           'tensiononly', or 'compressiononly'.
%           This determines how the principal axis of strain is determined.
%           The principal axis is always one of the two axes that lie
%           within the plane of the mesh.
%           For 'abs', it is the direction with the greatest absolute value
%           of the strain.
%           For 'tension', it is the direction of greatest tension/least
%           compression.
%           For 'compression', it is the direction of greatest compression/
%           least tension.
%           'compressiononly' is the same as 'compression', except that the growth
%           tensor will be set to zero if all of the in-place components of
%           strain are tensive.
%           'tensiononly' is the same as 'tension', except that the growth
%           tensor will be set to zero if all of the in-place components of
%           strain are compressive.
%       'scaling': A number, default value 1. After the growth tensors have
%           been calculated according to all the other parameters, they are
%           multiplied by this factor.
%       'proportional': If false (the default) then the magnitude of growth
%           is set solely by the growth morphogens KAPAR etc.  If true, the
%           magnitudes are additionally multiplied by the absolute
%           magnitudes of the strain relative to their maximum absolute
%           magnitudes.
%       'useanisotropy':
%           If false (the default), the principal value of the strain is
%           use to scale both the parallel and perpendicular directions of
%           growth. If true, the principal strain scales the parallel
%           growth, and the sub-principal strain scales the perpendicular
%           growth.
%       'usenormalstrain': If false (the default) then the residual strain
%           normal to the surface are treated as zero.  The resulting
%           growth tensors will thus have zero specified growth normal to
%           the mesh.  If true, then the normal stress is used to define the
%           normal growth, in the same way as for the other components.
%       'twosided': if true, the residual strain values on  thetwo sides
%           of the mesh are used as is.  If false (the default), they are
%           averaged with each other and the average values are used for
%           both sides. In other words, residual bending strains are
%           ignored.  (THIS IS NOT IMPLEMENTED YET: THE PROCEDURE ALWAYS
%           SETS THIS OPTION TO FALSE.)
%       'strain': if absent (the default), the procedure operates on the
%           residual strains stored in the mesh.  Instead, the user can
%           supply their own tensors here as an N*6 array, where N is the
%           number of finite elements.  Most users are not expected to use
%           this option.
%       'nozeros': Default is false.  If true, any tensors that would be
%           zero are replaced by [1 1 1 0 0 0] i.e. the
%
%   See also:
%       leaf_setGrowthTensors

    if nargout >= 2
        tensors = [];
    end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
        'mode', 'abs', ...
        'scaling', 1, ...
        'proportional', false, ...
        'useanisotropy', false, ...
        'usenormalstrain', false, ...
        'twosided', false, ...
        'strain', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'mode', 'scaling', 'proportional', 'useanisotropy', 'usenormalstrain', 'twosided', 'strain' );
    if ~ok, return; end
    s.twosided = false;  % Two-sided is not implemented yet.
    
    if isempty( s.strain )
        if s.twosided
            strainA = m.outputs.residualstrain.A;
            strainB = m.outputs.residualstrain.B;
        else
            strainA = (m.outputs.residualstrain.A + m.outputs.residualstrain.B)/2;
            strainB = [];
        end
    else
        strainA = s.strain;
        strainB = [];
    end
    mgenindexes = FindMorphogenRole( m, { 'KAPAR', 'KAPER', 'KBPAR', 'KBPER', 'KNOR' } );
    % mgenindexes = FindMorphogenIndex( m, { 'KAPAR', 'KAPER', 'KBPAR', 'KBPER', 'KNOR' } );
    mgensPerFE = perVertextoperFE( m, m.morphogens(:,mgenindexes), 'mid' );
    strainGrowth = modifyStrain( strainA, strainB, mgensPerFE, ...
        s.proportional, s.usenormalstrain, ...
        s.useanisotropy, s.mode );
    strainGrowth = s.scaling * strainGrowth;
    
%     if ~s.proportional
%         zerotensors = all(strainGrowth==0,2);
%         numz = sum(zerotensors);
%         strainGrowth( zerotensors, : ) = [ ones( numz, 3 ) zeros( numz, 3 ) ];
%     end
    
    m = leaf_setGrowthTensors( m, strainGrowth );
    if nargout >= 2
        tensors = strainGrowth;
    end
end


function [newstrain,totalstrain] = modifyStrain( strainA, strainB, mgensPerFE, ...
                            proportional, usenormal, useanisotropy, mode )
%     tic;
    twosided = ~isempty(strainB);
    strain = [ strainA; strainB ];
    newstrain = zeros( size(strain) );
    v = zeros(3,3,size(strain,1));
    d = zeros(size(strain,1),3);
    for i=1:size(strain,1)
        % [v(:,:,i),d(i,:)] = eig( convert6vectorTo33matrix( strain(i,:) ), 'vector' );
        [v(:,:,i),dmat] = eig( convert6vectorTo33matrix( strain(i,:) ) );
        d(i,:) = diag(dmat)';
    end
    [~,zi] = max(abs(v(3,:,:)),[],2);
    zi = squeeze(zi);
    zj = mod(zi,3)+1;
    zk = mod(zj,3)+1;
    g0 = zeros(size(strain,1),1);
    g1 = g0;
    g2 = g0;
    for i=1:size(strain,1)
        g0(i) = d(i,zi(i));
        g1(i) = d(i,zj(i));
        g2(i) = d(i,zk(i));
    end
    if ~usenormal
        g0(:) = 0;
    end

    gparper = [g1,g2];
    zparper = [zj,zk];
    switch mode
        case {'tension','tensiononly'}
            [gparper,perm] = sort(gparper,2,'descend');
            if strcmp(mode,'tensiononly')
                notension = all(gparper<=0,2);
                gparper(notension,:) = 0;
            end
        case { 'compression','compressiononly'}
            [gparper,perm] = sort(gparper,2);
            if strcmp(mode,'compressiononly')
                notension = all(gparper>=0,2);
                gparper(notension,:) = 0;
            end
        case 'abs'
            [~,perm] = sort(abs(gparper),2,'descend');
            for i=1:size(strain,1)
                gparper(i,:) = gparper(i,perm(i,:));
            end
    end
    for i=1:size(strain,1)
        zparper(i,:) = zparper(i,perm(i,:));
    end
        
    scaling = max(abs(gparper(:)));
    if scaling > 0
        gparper = gparper/scaling;
    end
    
    h0 = abs(g0);
    
    if proportional
        if useanisotropy
            hparper = gparper .* mgensPerFE(:,[1 2]);
        else
            hparper = gparper(:,[1 1]) .* mgensPerFE(:,[1 2]);
        end
    else
        totgparper = sum(abs(gparper),2);
        ztotg = totgparper == 0;
        nztotg = ~ztotg;
        gparper(ztotg,:) = 1;
        mgensPerFE(ztotg,[1 2]) = repmat( sum( mgensPerFE(ztotg,[1 2]), 2 )/2, 1, 2 );
        if useanisotropy
            gparper(nztotg,:) = gparper(nztotg,:)./repmat(totgparper(nztotg),1,2);
            hparper = gparper .* mgensPerFE(:,[1 2]);
        else
            hparper = mgensPerFE(:,[1 2]);
        end
        hparper(ztotg,:) = repmat( sum(hparper(ztotg,:),2)/2, 1, 2 );
    end
    
    for i=1:size(strain,1)
        neweigs([zi(i) zparper(i,:)]) = [h0(i) hparper(i,:)];
        ns = v(:,:,i)*diag(neweigs)*v(:,:,i)';
        newstrain(i,:) = make6vector( ns );
        if max(abs(hparper)) > 10
            xxxx = 1;
        end
    end
    totalstrain = sum(hparper,2);
    if twosided
        newstrain = permute( reshape( newstrain, [], 2, size(newstrain,2) ), [1 3 2] );
        totalstrain = reshape( totalstrain, [], 2 );
    end
%     toc
end

