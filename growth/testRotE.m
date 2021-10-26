function testRotE( rta )
    fprintf( 1, 'testRotE\n' );
    E = 10
    nu = 0.35
    G = 1
    lambda = 3*E*nu/(1+nu)
    mu = lambda*(1/(2*nu) - 1)
  % D = IsotropicStiffnessMatrix( E, nu )
    D = SemiOrthotropicStiffnessMatrix( E, E/2, nu, nu, nu*2, G, G )
    rotAngle = pi*rta;
    s = sin(rotAngle);
    c = sqrt( 1 - s*s );
    J = [ c s 0;
         -s c 0;
          0 0 1 ];
    rotD = rotateElastMatrix( D, J )
end

function k = sixi( i, j )
    if i==j
        k = i;
    else
        k = 9 - i - j;
    end
end

function [i,j] = t33i( ij )
    ij2i = [1,2,3,2,3,1];
    ij2j = [1,2,3,3,1,2];
    i = ij2i(ij);
    j = ij2j(ij);
end

function t = Isot1( lambda, mu )
    for i=1:3
        for k=1:3
            for j=1:3
                for l=1:3
                    t(i,j,k,l) = lambda*(i==j)*(k==l) ...
                        + mu*((i==k)*(j==l) + (i==l)*(j==k));
                end
            end
        end
    end
end

function t = sixvecToTensor( v )
    t = [ [ v(1), v(3), v(2) ]; ...
          [ v(3), v(2), v(1) ]; ...
          [ v(2), v(3), v(1) ] ];
end

function checksym( t, i, j )
    if t(i,j) ~= t(j,i)
        fprintf( 1, 'Symmetry error: t(%d,%d) %f, t(%d,%d) %f, diff %f\n', ...
            i, j, t(i,j), j, i, t(j,i), t(i,j)-t(j,i) );
    end
end

function v = tensorToSixvec( t )
    checksym( t, 1, 2 );
    checksym( t, 2, 3 );
    checksym( t, 3, 1 );
    v = [ t(1,1), t(2,2), t(3,3), t(2,3), t(3,1), t(1,2) ];
end

function t = sixmatToTensor( m )
    rot2 = [2,3,1];

    % t has 81 elements.
    t = zeros( 3, 3, 3, 3 );
    
    % Each line sets 9 elements. 9 lines, 81 total.
    for i=1:3
        for j=1:3
            t(i,i,j,j) = m(i,j);
            t(i,rot2(i),j,j) = m(i+3,j);
            t(rot2(i),i,j,j) = m(i+3,j);
            t(i,i,j,rot2(j)) = m(i,j+3);
            t(i,i,rot2(j),j) = m(i,j+3);
            t(i,rot2(i),j,rot2(j)) = m(i+3,j+3);
            t(rot2(i),i,j,rot2(j)) = m(i+3,j+3);
            t(i,rot2(i),rot2(j),j) = m(i+3,j+3);
            t(rot2(i),i,rot2(j),j) = m(i+3,j+3);
        end
    end
end

function m = tensorToSixmat( t )
    rot2 = [2,3,1];
    for i=1:3
        for j=1:3
            m(i,j) = t(i,i,j,j);
            m(i+3,j) = t(i,rot2(i),j,j);
            m(i,j+3) = t(i,i,j,rot2(j));
            m(i+3,j+3) = t(i,rot2(i),j,rot2(j));
        end
    end
end

function print3333( msg, t )
    fprintf( '%s\n', msg );
    for i=1:3
        for k=1:3
            for j=1:3
                fprintf( 1, '  ' );
                for l=1:3
                    fprintf( ' %5.2f', t(i,j,k,l) );
                end
            end
            fprintf( 1, '\n' );
        end
        fprintf( 1, '\n' );
    end
end


