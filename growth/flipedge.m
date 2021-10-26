function m = flipedge( m, eis )
%m = flipedge( m, eis )
% For each ei in eis, ei is the index of an edge that has a triangle on
% both sides. 
% Those two triangles form a quadrilateral of which the given edge is a
% diagonal.  flipedge replaces that edge by the other diagonal.

    areachange = 0;
    for i=1:length(eis)
        ei = eis(i);
        cells = m.edgecells( ei, : );
        c1 = cells(1);
        c2 = cells(2);
        if c2==0, return; end
        avgradpol = permute( (m.gradpolgrowth(c1,:,:) + m.gradpolgrowth(c2,:,:))/2, [3 2 1] );
      % vxs = m.tricellvxs(ci,:);
      % m.gradpolgrowth( ci, : ) = -trianglegradient( m.nodes( vxs, : ), m.polfreeze(ci,:) );
        areachange = areachange - m.cellareas(c1) - m.cellareas(c2);
      % edgevxs = m.edgeends( ei, : );
        ces1 = m.celledges( c1, : );
        ces2 = m.celledges( c2, : );
        cvs1 = m.tricellvxs( c1, : );
        cvs2 = m.tricellvxs( c2, : );
        cei1_1 = find( ces1==ei );
        [cei1_2,cei1_3] = othersOf3( cei1_1 );
        v1_1 = cvs1( cei1_1 );
        v1_2 = cvs1( cei1_2 );
        v1_3 = cvs1( cei1_3 );
        ei1_2 = ces1( cei1_2 );
        ei1_3 = ces1( cei1_3 );
        cei2_1 = find( ces2==ei );
        [cei2_2,cei2_3] = othersOf3( cei2_1 );
        v2_1 = cvs2( cei2_1 );
        v2_2 = cvs2( cei2_2 );
        v2_3 = cvs2( cei2_3 );
        ei2_2 = ces2( cei2_2 );
        ei2_3 = ces2( cei2_3 );
        if v1_2 ~= v2_3 % Should not happen since we enforced orientedness of the mesh.
            x = v2_3; v2_3 = v2_2; v2_2 = x;
            x = ei2_3; ei2_3 = ei2_2; ei2_2 = x;
        end
        if (v1_2 ~= v2_3) || (v1_3 ~= v2_2)
            fprintf( 1, '%s: invalid edge v1_2 %d v1_3 %d v2_2 %d v2_3 %d\n', ...
                mfilename(), v1_2, v1_3, v2_2, v2_3 );
            error('%s failure', mfilename());
        end
            
        % check v1_2 == v2_3, v1_3==v2_2

        if false
            fprintf( 1, 'Flipping edge %d for cells %d, %d.\n', ei, c1, c2 );
            fprintf( 1, 'Cell %d vxs %d %d %d, edges %d %d %d\n', ...
                c1, cvs1, ces1 );
            fprintf( 1, 'Cell %d vxs %d %d %d, edges %d %d %d\n', ...
                c2, cvs2, ces2 );
            fprintf( 1, 'Other diagonal %d %d\n', v1_1, v2_1 );
            fprintf( 1, 'New cell %d vxs %d %d %d, edges %d %d %d\n', ...
                c1, v1_3, v1_1, v2_1, ei, ei2_3, ei1_2 );
            fprintf( 1, 'New cell %d vxs %d %d %d, edges %d %d %d\n', ...
                c2, v2_3, v2_1, v1_1, ei, ei1_3, ei2_2 );
        end
        m.edgeends( ei, : ) = [ v1_1, v2_1 ];
        m.tricellvxs( c1, : ) = [ v1_3, v1_1, v2_1 ];
        m.tricellvxs( c2, : ) = [ v2_3, v2_1, v1_1 ];
        m.celledges( c1, : ) = [ ei, ei2_3, ei1_2 ];
        m.celledges( c2, : ) = [ ei, ei1_3, ei2_2 ];
        m.edgecells( ei1_3, (m.edgecells( ei1_3, : )==c1) ) = c2;
        m.edgecells( ei2_3, (m.edgecells( ei2_3, : )==c2) ) = c1;
        m.cellareas(c1) = findcellarea( m, c1 );
        m.cellareas(c2) = findcellarea( m, c2 );
        areachange = areachange + m.cellareas(c1) + m.cellareas(c2);
        e = ces1( cei1_1 );
        m.nodecelledges{v1_1} = replaceNCE( ...
            m.nodecelledges{v1_1}, c1, [c2, e, c1] );
        m.nodecelledges{v2_1} = replaceNCE( ...
            m.nodecelledges{v2_1}, c2, [c1, e, c2] );
        m.nodecelledges{v1_3} = replaceNCE( ...
            m.nodecelledges{v1_3}, [c1, e, c2], c1 );
        m.nodecelledges{v2_3} = replaceNCE( ...
            m.nodecelledges{v2_3}, [c2, e, c1], c2 );
        % Set m.polfreeze for c1 and c2 to average of old effective gradients.
        m.polfreeze(c1,:,:) = permute( globalToLocalGradient( avgradpol, m.nodes(m.tricellvxs(c1,:),:) ), [3 2 1] );
        m.polfreeze(c2,:,:) = permute( globalToLocalGradient( avgradpol, m.nodes(m.tricellvxs(c2,:),:) ), [3 2 1] );
        m.polfreezebc(c1,:,:) = permute( vec2bc( avgradpol, m.nodes(m.tricellvxs(c1,:),:) ), [3 2 1] );
        m.polfreezebc(c2,:,:) = permute( vec2bc( avgradpol, m.nodes(m.tricellvxs(c2,:),:) ), [3 2 1] );
        m = calcPolGrad( m, [c1,c2] );
    end
    m.globalDynamicProps.currentArea = m.globalDynamicProps.currentArea + areachange;
    
    % Find all second layer vertexes in the affected cells and recompute
    % their coordinates.
    if hasNonemptySecondLayer( m )
        changedCellMap = false(size(m.tricellvxs,1),1);
        changedCellMap([c1 c2]) = true;
        biovxsToFix = find(changedCellMap(m.secondlayer.vxFEMcell));
        m = fixSecondLayer( m, biovxsToFix, [c1 c2] );
    end
end

function a = replaceNCE( a, a1, a2 )
%a = replaceNCE( a, a1, a2 )

    alen = size(a,2);
    a1len = floor(length(a1)/2);
    a1start = find( a(2,:)==a1(1), 1 );
    a1end = mod(a1start+a1len-1,alen)+1;
    a2e = a2(2:2:end);
    a2c = a2(1:2:end);
    insert = [ [ a(1,a1start), a2e ]; a2c ];
    if a1start <= a1end
        a = [ a(:,1:(a1start-1)), ...
              insert, ...
              a(:,(a1end+1):alen) ];
    else
        a = [ a(:,(a1end+1):(a1start-1)), insert ];
    end
end
