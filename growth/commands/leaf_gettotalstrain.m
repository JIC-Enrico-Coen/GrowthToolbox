function totalstrain = leaf_gettotalstrain( m, varargin )
%totalstrain = leaf_gettotalstrain( m, varargin )
%
%   Calculate the total residual strain along any subset of its principal
%   axes.
%
%   Options:
%       'abs': If true (the default) then the total strain is calculated as
%           the sum of the absolute values of the selected principal
%           components.  If false, the algebraic sum is taken.
%       'axes': This specifies which principal components of strain are
%           included in the sum.  The default is 'tension'.  Possibilities
%           are:
%           'total': all of the principal strains.
%           'areal': the principal strain parallel to the mesh surface.
%           'normal': only the principal strain perpendicular to the
%               surface.
%           'tension': of the two principal axes parallel to the mesh
%               surface, the one having greatest tension/least compression.
%           'compression': of the two principal axes parallel to the mesh
%               surface, the one having greatest compression/least tension.
%           'maxabs': of the two principal axes parallel to the mesh
%               surface, the one having greatest absolute value.
%       'perFE': A boolean. If true, the result is returned as a single
%           value per finite element.  If false (the default) the result is
%           converted to a single value per vertex.  This case is useful
%           for setting the polariser to the result of this function.  The
%           gradient of polariser is then the gradient of total strain.
%       'nonneg': A boolean.  If true), then the returned
%           values will, if necessary, have a constant added to them so
%           that the minimum value is never negative.  If false (the
%           default), this is not done.
%       'strain': if absent (the default), the procedure operates on the
%           residual strains stored in the mesh.  Instead, the user can
%           supply their own tensors here as an N*6 array, where N is the
%           number of finite elements. Most users are not expected to use
%           this option.

    if isempty(m)
        totalstrain = [];
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
        'abs', true, ...
        'axes', 'tension', ...
        'perFE', false, ...
        'nonneg', false, ...
        'strain', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'abs', 'axes', 'perFE', 'nonneg', 'strain' );
    if ~ok, return; end
    
    if isempty( s.strain )
        strain = (m.outputs.residualstrain.A + m.outputs.residualstrain.B)/2;
    else
        strain = s.strain;
    end
    
    if strcmp( s.axes, 'total' ) && ~s.abs
        % In this case we take the trace of the strain matrix, which
        % is invariant under rotations.  There is no need to find the
        % principal axes and eigenvalues.
        totalstrain = sum( strain(:,1:3), 2 );
    else
        % For all other cases we have to determine principal components and
        % select the requested subset of eigenvalues.
        v = zeros(3,3,size(strain,1));
        d = zeros(size(strain,1),3);
        for i=1:size(strain,1)
            % [v(:,:,i),d(i,:)] = eig( convert6vectorTo33matrix( strain(i,:) ), 'vector' );
            [v(:,:,i),dmat] = eig( convert6vectorTo33matrix( strain(i,:) ) );
            d(i,:) = diag(dmat)';
        end
        if s.abs
            d = abs(d);
        end
        if strcmp( s.axes, 'total' )
            totalstrain = sum(d,2);
        else
            [~,zi] = max(abs(v(3,:,:)),[],2);
            zi = squeeze(zi);
            zj = mod(zi,3)+1;
            zk = mod(zj,3)+1;
            % zi is the index of the normal axis.  zj and zk are the other
            % two axes.
            n = size(d,1);
            di = d( (1:n)' + (zi-1)*n );
            dj = d( (1:n)' + (zj-1)*n );
            dk = d( (1:n)' + (zk-1)*n );
            switch s.axes
                case 'areal'
                    totalstrain = dj+dk;
                case 'normal'
                    totalstrain = di;
                case 'tension'
                    djk = [dj dk];
                    [~,which] = max( djk, [], 2 );
                    totalstrain = dj;
                    totalstrain(which==2) = dk(which==2);
                case 'compression'
                    djk = [dj dk];
                    [~,which] = min( djk, [], 2 );
                    totalstrain = dj;
                    totalstrain(which==2) = dk(which==2);
                case 'maxabs'
                    djk = abs([dj dk]);
                    [~,which] = max( djk, [], 2 );
                    totalstrain = dj;
                    totalstrain(which==2) = dk(which==2);
            end
        end
    end
    if ~s.perFE
        totalstrain = perFEtoperVertex( m, totalstrain );
    end
    if s.nonneg
        minstrain = min(totalstrain);
        if minstrain < 0
            totalstrain = totalstrain - minstrain;
        end
    end
end
