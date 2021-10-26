function [wts,pis,pos] = butterfly3( m, ci, bc, tension )
%pos = butterfly3( m, ci, bc, tension )
%   Generalises the butterfly algorithm to pick a point corresponding to
%   the point in cell ci with barycentric coordinates bc.
%
%   The resulting surface is continuous but not smooth across edges and
%   vertexes.

    if nargin < 4
        tension = 1/16;
    end

    [p1,p1a,p12,p13] = getoneside( ci, 1 );
    [p2,p2a,p23,p21] = getoneside( ci, 2 );
    [p3,p3a,p31,p32] = getoneside( ci, 3 );
    
    pis = [ [p1; p1a; p12; p13], [p2; p2a; p23; p21], [p3; p3a; p31; p32] ];
    if true % New version, handles border edges.
        t2 = tension*2;
        t4 = tension*4;

        edgesplinewts = [ t2, -t2 ];
        butterflywts = [ 0, t4, -t4, t4, -t4 ];
        wts = [ bc; zeros(3,3) ];

        for a=1:3
            b = mod(a,3)+1;
            c = mod(b,3)+1;
            amt = 2*bc(b)*bc(c);
            if pis(2,a)==0
              % fprintf( 1, 'Edge: a %d\n', a );
                addwts = edgesplinewts*amt;
                wts = addweights( wts, [1 3], [b a], addwts*2*bc(b) );
                wts = addweights( wts, [1 4], [c a], addwts*2*bc(c) );
            else
              % fprintf( 1, 'Interior: a %d\n', a );
                addwts = butterflywts*amt;
                wts = addweights( wts, [1 2 3 1 2], [b a a a c], addwts*bc(b) );
                wts = addweights( wts, [1 2 4 1 2], [c a a a b], addwts*bc(c) );
            end
        end
        if true
            for a=1:3
                b = mod(a,3)+1;
                c = mod(b,3)+1;
                if pis(2,a)==0
                    x = wts(2,a);
                    if x ~= 0
                        wts(1,b) = wts(1,b) + x;
                        wts(1,c) = wts(1,c) + x;
                        wts(1,a) = wts(1,a) - x;
                        wts(2,a) = 0;
                    end
                end
                if pis(3,b)==0
                    x = wts(3,b);
                    if x ~= 0
                        wts(1,c) = wts(1,c) + x;
                        wts(2,b) = wts(2,b) + x;
                        wts(1,a) = wts(1,a) - x;
                        wts(3,b) = 0;
                    end
                end
                if pis(4,c)==0
                    x = wts(4,c);
                    if x ~= 0
                        wts(1,b) = wts(1,b) + x;
                        wts(2,c) = wts(2,c) + x;
                        wts(1,a) = wts(1,a) - x;
                        wts(4,c) = 0;
                    end
                end
            end
        end
      % wts
      % sumwts = sum(sum(wts))
    end
    
    if false % Old method, does not take account of edges.
        wts = b3weights( bc, tension );

        for i=1:3
            j = mod(i,3)+1;
            k = mod(j,3)+1;
            if pis(3,i)==0
                % 12 = 1a + 2 - 3
                dw = zeros(2,3);
                dw(2,i) = 1;
                dw(1,j) = 1;
                dw(1,k) = -1;
                wts(1:2,:) = wts(1:2,:) + wts(3,i)*dw; % [ 0 1 -1; 1 0 0 ];
                wts(3,i)= 0;
            end
            if pis(4,i)==0
                % 13 = 1a + 3 - 2
                dw = zeros(2,3);
                dw(2,i) = 1;
                dw(1,j) = -1;
                dw(1,k) = 1;
                wts(1:2,:) = wts(1:2,:) + wts(4,i)*dw; % [ 0 -1 1; 1 0 0 ];
                wts(4,i)= 0;
            end
            if pis(2,i)==0
                % 1a = 2 + 3 - 1
                dw = ones(1,3);
                dw(i) = -1;
                wts(1,:) = wts(1,:) + wts(2,i)*dw; % [ -1 1 1 ]
                wts(2,i)= 0;
            end
        end
        pis
        wts
        sumwts = sum(sum(wts))
    end
    pis = pis( wts ~= 0 )';
    wts = wts( wts ~= 0 )';
    
    pos = wts * m.nodes( pis, : );
    
        
function [xp1,xp1a,xp12,xp13] = getoneside( ci, cei )
    xp1 = m.tricellvxs( ci, cei );
    xe1 = m.celledges( ci, cei );
    xc1 = othercell( m, ci, xe1 );
    if xc1==0
        xp1a = 0;
        xp2 = m.tricellvxs( ci, mod(cei,3)+1 );
        xp3 = m.tricellvxs( ci, mod(cei+1,3)+1 );
        [x,xp12] = nextborderedge( m, xe1, xp2 );
        [x,xp13] = nextborderedge( m, xe1, xp3 );
      % fprintf( 1, 'getoneside: border edge ci %d cei %d p123 %d %d %d p1a %d p12 %d p13 %d\n', ...
      %     ci, cei, xp1, xp2, xp3, xp1a, xp12, xp13 );
        return;
    end
    xc1e1 = find( m.celledges( xc1, : ) == xe1 );
    xp1a = m.tricellvxs( xc1, xc1e1 );
    xc1e12 = mod(xc1e1,3)+1;
    xe12 = m.celledges( xc1, xc1e12 );
    xc12 = othercell( m, xc1, xe12 );
    if xc12==0
        xp12 = 0;
    else
        xc12e12 = find( m.celledges( xc12, : ) == xe12 );
        xp12 = m.tricellvxs( xc12, xc12e12 );
    end
    xc1e13 = mod(xc1e1+1,3)+1;
    xe13 = m.celledges( xc1, xc1e13 );
    xc13 = othercell( m, xc1, xe13 );
    if xc13==0
       xp13 = 0;
    else
        xc13e13 = find( m.celledges( xc13, : ) == xe13 );
        xp13 = m.tricellvxs( xc13, xc13e13 );
    end
end

end

function pwts = addweights( pwts, pref1, pref2, wts )
    for i=1:length(wts)
        pwts(pref1(i),pref2(i)) = pwts(pref1(i),pref2(i)) + wts(i);
    end
    return;
    
    dwts = zeros(4,3);
    for i=1:length(wts)
        dwts(pref1(i),pref2(i)) = wts(i);
    end
    dwts
end
