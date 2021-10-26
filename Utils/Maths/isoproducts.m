function [M,volume] = isoproducts( vxs )
%M = isoproducts( vxs )
%   Calculate the integral of the product of any two isoparametric shape
%   functions over the pentahedron given by the 6*3 array vxs.  The
%   standard pentahedron has the vertex array:
%       [ 1 0 -1;
%         0 1 -1;
%         0 0 -1;
%         1 0 1;
%         0 1 1;
%         1 1 1 ];
%   and the given vertexes are assumed to be listed in the same order.
%
%   The result is a 6*6 array M, which is indexed along both dimensions by
%   the first index of vxs.
%
%   M is symmetric, and its upper right 3*3 quadrant is symmetric.
%   This means that the matrix has at most 18 independent elements.  This
%   must be an over-estimate, though.  M is a function of vxs, which
%   already only has 18 dfs.  M is invariant under volume-preserving linear
%   transformations, which have 8 dfs, leaving only 10 dfs for M.  10 is
%   the number of dfs of a symmetric 4*4 matrix.  Furthermore, M is
%   determined by the coefficients td1, tdx, etc. computed below.  There
%   are only 9 of these, so M has at most 9 degrees of freedom.  In fact,
%   tdxzz and tdyzz are identically zero, leaving only 7 dfs.
%
%   For the standard pentahedron, M is:
%     [ 4 2 2 2 1 1
%       2 4 2 1 2 1
%       2 2 4 1 1 2
%       2 1 1 4 2 2
%       1 2 1 2 4 2
%       1 1 2 2 2 4 ] / 72
%   Its elementwise reciprocal is:
%     [ 1 2 2 2 4 4
%       2 1 2 4 2 4
%       2 2 1 4 4 2
%       2 4 4 1 2 2
%       4 1 4 2 1 2
%       4 4 2 2 2 1 ] * 18
%   Its inverse is
%     [ 6 -2 -2 -3  1  1
%      -2  6 -2  1 -3  1
%      -2 -2  6  1  1 -3
%      -3  1  1  6 -2 -2
%       1 -3  1 -2  6 -2
%       1  1 -3 -2 -2  6 ] * 6
%
%   Under linear transformations M is scaled by the determinant, and hence
%   M is invariant under rigid motions and shears.
%
%   More general movements of the six vertices break much of the symmetry.
%
%   Pathological pentahedra can have zero volume, and in this case M is
%   singular.
%
%   When there is no interpenetration of faces, M is non-singular, and its
%   determinant has the same sign as the volume.  In finite element
%   calculations, the vertexes should be numbered in such a way that the
%   volume is positive.  This means that the outward surface normal for the
%   triangle vxs([4 5 6],:) should follow the right-hand rule for that
%   listing of those vertexes.
%
%   The standard pentahedron can be parameterised by the coordinates x, y,
%   and z.  Every other pentahedron can inherit this parameterisation, by
%   interpreting x and y as two of the barycentric coordinates on the
%   triangles vxs([1 2 3],:) and vxs([4 5 6],:), and z as parameterising
%   each of the lines vxs([1 4],:), vxs([2 5],:), and vxs([3 6],:). z thus
%   represents the pentahedron as a stack of triangles, to which the
%   barycentric coordinates x and y can be applied.
%
%   To obtain the integral of any quantity Q defined in terms of these
%   coordinates, one integrates over the standard pentahedron the quantity
%   Q*D, where D is the dilation of the mapping of the standard pentahedron
%   to the one we are integrating over.  D is the determinant of the
%   Jacobian of the transformation, as a function of the x, y, and z
%   coordinates in the standard pentahedron.  This is a cubic polynomial in
%   x, y, and z, the coefficients of which are calculated below as the
%   quantities tp1 (the linear term), tpx (the term in x), etc., up to
%   tpyzz (the term in y*z^2).  Each of these coefficients is a sum of
%   triple vector products of linear combinations of the vertexes of the
%   pentahedron.

%   There is scope for optimising this code.  The results of Mxyz should be
%   computed once and cached.  There are 1215 calls to Mxyz, but only 50
%   different sets of parameters, being all values of x, y, and z with x+y
%   in the range 0:3 and z in the range 0:4.  Only 30 of the values are
%   non-zero.  There is symmetry between i and j.  This leaves 18
%   independent non-zero values.  Some of these are multiplied only with
%   zero coefficients in the tpsx array, leaving just 16 useful values,
%   whose reciprocals are:
%      0     0     0     1
%      0     0     2     3
%      0     0     4     5
%      0     1     0     3
%      0     1     2     9
%      0     1     4    15
%      0     2     0     6
%      0     2     2    18
%      0     2     4    30
%      0     3     0    10
%      0     3     2    30
%      1     1     0    12
%      1     1     2    36
%      1     1     4    60
%      1     2     0    30
%      1     2     2    90
%   In fact, we can do better.  The result is a linear combination of the
%   values of tpsx, hence requires just 7 coefficients to be calculated,
%   coefficients which depend only on the standard pentahedron.  These can
%   be calculated just once and hard-wired.  This is done in the code below
%   to calculate svals, which is a 6*6 matrix for each row of tpsx.


%   Diffusion also needs the integrals of the dot products of the gradients
%   of the shape functions.  In progress.

    M = [];
    volume = [];


    if nargin < 1
        % Use the standard pentahedron.
        vxs = [ 1 0 -1;
                0 1 -1;
                0 0 -1;
                1 0 1;
                0 1 1;
                0 0 1 ] + rand(6,3);
%         vxs = [ 1 0 -1;
%                 0 1 -1;
%                 0 0 -1;
%                 2 0 3;
%                 0 4 5;
%                 0 0 6 ];
    end
    
    isp = integrateShapeProds( vxs )
    isgp = integrateShapeGradientProds( vxs )
    return;
    
%     m000A = integratePoly( [0 0 0 1], vxs );
%     m100A = integratePoly( [1 0 0 1], vxs );
%     m010A = integratePoly( [0 1 0 1], vxs );
%     
%     m000 = Mxyz(0,0,0);
%     m100 = Mxyz(1,0,0);
%     m010 = Mxyz(0,1,0);
%     m001 = Mxyz(0,0,1);
%     m200 = Mxyz(2,0,0);
%     m020 = Mxyz(0,2,0);
%     m110 = Mxyz(1,1,0);
%     m002 = Mxyz(0,0,2);
    
    tpsx = particularDataFast( vxs );
    M = isoproductgradientsSlowest( tpsx );
    volume = 0;
    err_M_isp = M-isp
    return;
    
%     [M,volume] = testIsoproducts( vxs );
%     
%     return;

    SS = calcSS();  % Should only be done once.
    tpsx = particularDataFast( vxs );
    % The numbers in the next line are the result of applying Mxyz to the
    % first three columns of tpsx as computed by particularData( vxs ) (but
    % which do not actually depend on vxs).
    volume = dot( tpsx, [1 1/3 1/3 0 0 0 1/3] );
    M = tpsx*SS;
    M = M( [ 1  6  5  7 12 11;
             6  2  4 12  8 10;
             5  4  3 11 10  9;
             7 12 11 13 18 17;
            12  8 10 18 14 16;
            11 10  9 17 16 15 ] );
end

function [M,volume] = testIsoproducts( vxs );

% global MXYZ
% MXYZ = zeros(0,4);


    if nargin < 1
        % Use the standard pentahedron.
%         vxs = [ 1 0 -1;
%                 0 1 -1;
%                 0 0 -1;
%                 1 0 1;
%                 0 1 1;
%                 0 0 1 ];
        vxs = [ 1 0 -1;
                0 1 -1;
                0 0 -1;
                2 0 3;
                0 4 5;
                0 0 6 ];
    end
    % plotpentahedron( vxs );
    
    
    tpsx = particularData( vxs );       
    volume = dot( tpsx(:,4), Mxyz( tpsx(:,1), tpsx(:,2), tpsx(:,3) ) );
    
    N = 1000;
    
    MS = isoproductsSlowest( tpsx );
    MSS = isoproductsSlow( tpsx );
    
    
    tic;
    for i=1:N
        tpsx = particularData( vxs );       
        MF = isoproductsFast( vxs, tpsx );
    end
    fprintf( 1, 'isoproductsFast: ' );
    toc;
    
    SS = calcSS();
    tic;
    for i=1:N
        tpsx = particularData( vxs );       
        MFF = isoproductsFaster( tpsx, SS );
    end
    fprintf( 1, 'isoproductsFaster: ' );
    toc;
    
    tic;
    for i=1:N
        tpsx = particularDataFast( vxs );       
        MFFF = tpsx*SS;
        MFFF = MFFF( [ 1  6  5  7 12 11;
                       6  2  4 12  8 10;
                       5  4  3 11 10  9;
                       7 12 11 13 18 17;
                      12  8 10 18 14 16;
                      11 10  9 17 16 15 ] );
    end
    fprintf( 1, 'isoproductsFastest inline: ' );
    toc;
    
    errMSSMS = MSS-MS;  errMSSMS = max(abs(errMSSMS(:)))
    errMSMF = MS-MF;  errMSMF = max(abs(errMSMF(:)))
    errMFMFF = MF-MFF;  errMFMFF = max(abs(errMFMFF(:)))
    errMFFMFFF = MF-MFFF;  errMFFMFFF = max(abs(errMFFMFFF(:)))
    
    M = MFFF;
    return;
                
%     function d = density( x, y, z )
%         % Calculate the local expansion of the mapping from the standard
%         % pentahedron to an arbitrary one at isoparametric coordinates
%         % (x,y,z).
%         d = det( [ dx1 + z*dxz; dy1 + z*dyz; dz1 + x*dzx + y*dzy ] )/2;
%     end

end

% function td = TDxyz( i, j, k, tpsx )
%     td = dot( tpsx(:,4), Mxyz( tpsx(:,1)+i, tpsx(:,2)+j, tpsx(:,3)+k ) );
% end

function M = isoproductgradientsSlowest( tpsx )
    % Each of the matrices nsA is a 6*6 matrix in which the (i,j) element
    % is the coefficient of A in grad(Ni).grad(Nj), A being a product of
    % powers of x, y, and z.
    
    % This code has not been checked yet.
    % It appears to be wrong.  It calculates grad(Ni).grad(Nj) in the
    % canonical pentahedron and integrates this over the general
    % pentahedron.  It should do all of the calculations in the general
    % pentahedron.
    
    ns1 = repmat( [ 1 0 -1;
                    0 1 -1;
                   -1 -1 3 ], [2 2] );
    nsx = repmat( [ 0 0 1;
                    0 0 0;
                    1 0 -2 ], [2 2] );
    nsy = repmat( [ 0 0 0;
                    0 0 1;
                    0 1 -2 ], [2 2] );
    nsz = [ -2 0 2;
             0 -2 2
             2 2 -4 ];
    nsz = [ nsz, zeros(3); zeros(3), -nsz ];
    nsxx = repmat( [ 1 0 -1;
                     0 0 0;
                    -1 0 1 ], [2 2] );
    nsyy = repmat( [ 0 0 0;
                     0 1 -1;
                     0 -1 1 ], [2 2] );
    nsxy = repmat( [ 0 1 -1;
                     1 0 -1;
                     -1 -1 2 ], [2 2] );
    nszz = [ 1 0 -1;
             0 1 -1;
            -1 -1 2 ];
    nszz = [ nszz, -nszz; -nszz, nszz ];
    nss = reshape( [ ns1, nsx, nsy, nsz, nsxx, nsyy, nsxy, nszz ], [6, 6, 8] );
    nspowers = [ 0 0 0;
                 1 0 0;
                 0 1 0;
                 0 0 1;
                 2 0 0;
                 0 2 0;
                 1 1 0;
                 0 0 2 ];
    M = zeros(6,6);
    tpsxp = tpsxpowers();
    c = zeros( size(tpsxp,1), size(nspowers,1) );
    for k=1:size(nspowers,1)
        c(:,k) = Mxyz( tpsxp(:,1)+nspowers(k,1), tpsxp(:,2)+nspowers(k,2), tpsxp(:,3)+nspowers(k,3) );
    end
    % c*180
    tpsxc = tpsx*c;
    for k=1:size(nspowers,1)
        M = M + nss(:,:,k)*tpsxc(k); % dot( tpsx, c(:,k) );
    end
    M = M/4;
end

function M = isoproductsSlowest( tpsx )
    % The shape function for vertex 1 is N1 = x(1-z)/2.
    % So the integral of N1*N1 is the integral of xx(1-z)(1-z)/4, which
    % should be (tdxx - 2*tdxxz + tdxxzz)/4.
    
    nx = [1 0 0 1];
    ny = [0 1 0 1];
    n1xy = [0 0 0 1; 1 0 0 -1; 0 1 0 -1];
    nzlo = [0 0 0 1/2; 0 0 1 -1/2];
    nzhi = [0 0 0 1/2; 0 0 1 1/2];
    % ns contains the shape functions for the six vertexes.
    ns = { polyprod( nx, nzlo ), polyprod( ny, nzlo ), polyprod( n1xy, nzlo ), ...
           polyprod( nx, nzhi ), polyprod( ny, nzhi ), polyprod( n1xy, nzhi ) };
    
    M = zeros(6,6);
    for i=1:6
        for j=i:6
            nij = polyprod(ns{i},ns{j});
            for k=1:size(nij,1)
                c = Mxyz( tpsx(:,1)+nij(k,1), tpsx(:,2)+nij(k,2), tpsx(:,3)+nij(k,3) );
                M(i,j) = M(i,j) + nij(k,4)*dot( tpsx(:,4), c );
            end
            M(j,i) = M(i,j);
        end
    end
end

function M = isoproductsSlow( tpsx )
    % The shape function for vertex 1 is N1 = x(1-z)/2.
    % So the integral of N1*N1 is the integral of xx(1-z)(1-z)/4, which
    % should be (tdxx - 2*tdxxz + tdxxzz)/4.
    
    nx = [1 0 0 1];
    ny = [0 1 0 1];
    n1xy = [0 0 0 1; 1 0 0 -1; 0 1 0 -1];
    nzlo = [0 0 0 1/2; 0 0 1 -1/2];
    nzhi = [0 0 0 1/2; 0 0 1 1/2];
    
    % ns contains the shape functions for the six vertexes.
    ns = { polyprod( nx, nzlo ), polyprod( ny, nzlo ), polyprod( n1xy, nzlo ), ...
           polyprod( nx, nzhi ), polyprod( ny, nzhi ), polyprod( n1xy, nzhi ) };

    svals = cell(1,7);
    for ti = 1:size(tpsx,1)
        MC = zeros(6,6);
        for i=1:6
            for j=i:6
                nij = polyprod(ns{i},ns{j});
                for k=1:size(nij,1)
                    c = Mxyz( tpsx(ti,1)+nij(k,1), tpsx(ti,2)+nij(k,2), tpsx(ti,3)+nij(k,3) );
                    MC(i,j) = MC(i,j) + nij(k,4)*c;
                end
                MC(j,i) = MC(i,j);
            end
        end
        svals{ti} = MC;
        % MC1 = 1./MC
    end
    M = zeros(6,6);
    for ti = 1:size(tpsx,1)
        M = M + svals{ti}*tpsx(ti,4);
    end
end

function M = isoproductsFast( vxs, tpsx )
% Calculate data about the canonical pentahedron.
    ss = calcSS();

% Combine with data about the particular pentahedron.
    M = tpsx(:,4)'*ss;
    
% Reindex to a square array.
    M = M( [ 1  6  5  7 12 11;
             6  2  4 12  8 10;
             5  4  3 11 10  9;
             7 12 11 13 18 17;
            12  8 10 18 14 16;
            11 10  9 17 16 15 ] );
end


function ss = calcSS()
% Hard-wired data about the canonical pentahedron.
    s1  = [4 4 4 2 2 2]/72;    s1  = [ s1, s1/2, s1 ];
    sx  = [12 4 4 2 4 4]/360;  sx  = [ sx, sx/2, sx ];
    sy  = [4 12 4 4 2 4]/360;  sy  = [ sy, sy/2, sy ];
    sz  = [2 2 2 1 1 1]/72;    sz  = [ -sz, 0 0 0 0 0 0, sz];
    sxz = [6 2 2 1 2 2]/360;   sxz = [ -sxz, 0 0 0 0 0 0, sxz];
    syz = [2 6 2 2 1 2]/360;   syz = [ -syz, 0 0 0 0 0 0, syz];
    szz = [8 8 8 4 4 4]/360;   szz = [ szz, szz/4, szz ];
    ss  = [ s1; sx; sy; sz; sxz; syz; szz ];
end

function M = isoproductsFaster( tpsx, SS )
% Combine with tpsx (data about the particular pentahedron) with SS (data
% about the canonical pentahedron).
    M = tpsx(:,4)'*SS;
    
% Reindex to a square array.
    M = M( [ 1  6  5  7 12 11;
             6  2  4 12  8 10;
             5  4  3 11 10  9;
             7 12 11 13 18 17;
            12  8 10 18 14 16;
            11 10  9 17 16 15 ] );
end

function J = isoparJacobian( vxs )
    J = [ tpsxpowers(), particularDataFast( vxs )' ];
end

function tpsxp = tpsxpowers()
    tpsxp = [ 0 0 0;
              1 0 0;
              0 1 0;
              0 0 1;
              1 0 1;
              0 1 1;
              0 0 2 ];
end

function tpsx = particularData( vxs )
%   Perform that part of the calculation which depends on the particular
%   pentahedron.

    v1 = vxs(1,:);
    v2 = vxs(2,:);
    v3 = vxs(3,:);
    v4 = vxs(4,:);
    v5 = vxs(5,:);
    v6 = vxs(6,:);
    
    v13 = (v1-v3)/2;
    v46 = (v4-v6)/2;
    v23 = (v2-v3)/2;
    v56 = (v5-v6)/2;
    v36 = (v3-v6)/2;
    
    dx1 = v13 + v46; % (+v1-v3+v4-v6)/2;
    dxz = -v13 + v46; % (-v1+v3+v4-v6)/2;
    dy1 = v23 + v56; % (+v2-v3+v5-v6)/2;
    dyz = -v23 + v56; % (-v2+v3+v5-v6)/2;
    dz1 = -v36; % (-v3+v6)/2;
    
    % We want half the triple product of these three vectors:
    % dx1 + z*dxz
    % dy1 + z*dyz
    % dz1 + x*dzx + y*dzy
    % for any point x, y, z.
    % This is a cubic polynomial in x, y, and z with terms for
    % 1, x, y, z, xz, yz, z^2, xz^2, and yz^2.  Each coefficient is a
    % combination of triple products of the vectors dAB we have just
    % calculated.  In general, all of these coefficients can be non-zero.
    % This procedure will return a representation of this polynomial.
    
    if false
        dzx = dxz;
        dzy = dyz;

        tp1 = det( [dx1; dy1; dz1] );
        tpx = det( [dx1; dy1; dzx] );
        tpy = det( [dx1; dy1; dzy] );
        tpz = det( [dx1; dyz; dz1] ) + det( [dxz; dy1; dz1] );
        tpxz = det( [dx1; dyz; dzx] ) + det( [dxz; dy1; dzx] );
        tpyz = det( [dx1; dyz; dzy] ) + det( [dxz; dy1; dzy] );
        tpyz = det( [dx1; dyz; dzy] ) + det( [dxz; dy1; dzy] );
        tpzz = det( [dxz; dyz; dz1] );
    else
        tp1 = det( [dx1; dy1; dz1] );
        tpx = det( [dx1; dy1; dxz] );
        tpy = det( [dx1; dy1; dyz] );

        tpz1 = det( [dx1; dyz; dz1] );
        tpz2 = det( [dxz; dy1; dz1] );
        tpz = tpz1+tpz2;
        
        tpxz = -det( [dxz; dyz; dx1] );
        tpyz = -det( [dxz; dyz; dy1] );
        tpzz = det( [dxz; dyz; dz1] );
    end
    
    % The following is a representation of a polynomial in three variables.
    % Each row is one term.  The first three elements are the powers of x,
    % y, and z, and the fourth is the coefficient.
    tpsx = [tpsxp, [ tp1; tpx; tpy; tpz; tpxz; tpyz; tpzz ] ];
end

function tpsx = particularDataFast( vxs )
%   Perform that part of the calculation which depends on the particular
%   pentahedron.
%
% The result is a representation of a polynomial in three variables.
% Each row is one term.  The first three elements are the powers of x,
% y, and z, and the fourth is the coefficient.

    v1 = vxs(1,:);
    v2 = vxs(2,:);
    v3 = vxs(3,:);
    v4 = vxs(4,:);
    v5 = vxs(5,:);
    v6 = vxs(6,:);
    
    v13 = (v1-v3)/2;
    v46 = (v4-v6)/2;
    v23 = (v2-v3)/2;
    v56 = (v5-v6)/2;
    v36 = (v3-v6)/2;
    
    dx1 = v13 + v46; % (+v1-v3+v4-v6)/2;
    dxz = -v13 + v46; % (-v1+v3+v4-v6)/2;
    dy1 = v23 + v56; % (+v2-v3+v5-v6)/2;
    dyz = -v23 + v56; % (-v2+v3+v5-v6)/2;
    dz1 = -v36; % (-v3+v6)/2;
    
    % We want half the triple product of these three vectors:
    % dx1 + z*dxz
    % dy1 + z*dyz
    % dz1 + x*dzx + y*dzy
    % for any point x, y, z.
    % This is a cubic polynomial in x, y, and z with terms for
    % 1, x, y, z, xz, yz, z^2, xz^2, and yz^2.  Each coefficient is a
    % combination of triple products of the vectors dAB we have just
    % calculated.  In general, all of these coefficients can be non-zero.
    
    if true
        tp1 = det( [dx1; dy1; dz1] );
        tpx = det( [dx1; dy1; dxz] );
        tpy = det( [dx1; dy1; dyz] );
        
        tpz1 = det( [dx1; dyz; dz1] );
        tpz2 = det( [dxz; dy1; dz1] );
        tpz = tpz1+tpz2;
        
        tpxz = -det( [dxz; dyz; dx1] );
        tpyz = -det( [dxz; dyz; dy1] );
        tpzz = det( [dxz; dyz; dz1] );
        tpsx = [ tp1 tpx tpy tpz tpxz tpyz tpzz ];
    else
        % This is slower.
        v = cross(dx1,dy1)*[dz1', dxz', dyz'];
        
        tpz1 = det( [dx1; dyz; dz1] );
        tpz2 = det( [dxz; dy1; dz1] );
        tpz = tpz1+tpz2;
        
        w = cross(dxz,dyz)*[-dx1', -dy1', dz1'];
        
        tpsx = [ v tpz w ];
    end
end

% function d = det3( m )
% % This is slower than the built-in det().
%     d = m(1)*(m(5)*m(9) - m(6)*m(8)) + m(2)*(m(6)*m(7)-m(4)*m(9)) + m(3)*(m(4)*m(8)-m(5)*m(7));
% end

function xx = quadlinspace( x1, x2, x3, x4, n )
    if nargin==2
        n = x2;
        x4 = x1(4);
        x3 = x1(3);
        x2 = x1(2);
        x1 = x1(1);
    end
    x12 = linspace( x1, x2, n );
    x34 = linspace( x3, x4, n );
    xx = zeros(n,n);
    for i=1:n
        xx(i,:) = linspace( x12(i), x34(i), n );
    end
end

function quadsurf( vxs, n )
    xx = quadlinspace( vxs(:,1), n );
    yy = quadlinspace( vxs(:,2), n );
    zz = quadlinspace( vxs(:,3), n );
    surf( xx, yy, zz );
end

function plotpentahedron( vxs )
    cla;
    hold on;
    plotpts( gca, vxs, '*' );
    connections = [1 2;
                   2 3;
                   3 1;
                   4 5;
                   5 6;
                   6 4;
                   1 4;
                   2 5;
                   3 6]';
    line( reshape(vxs(connections,1),size(connections)), ...
          reshape(vxs(connections,2),size(connections)), ...
          reshape(vxs(connections,3),size(connections)) );
    ndivs = 11;
    quadsurf( vxs([1 2 4 5],:), ndivs );
    quadsurf( vxs([2 3 5 6],:), ndivs );
    quadsurf( vxs([3 1 6 4],:), ndivs );
    hold off;
end

function m = Mxyz( i, j, k )
% Integral of x^i*y^j*z^k over the canonical pentahedron.

global MXYZ

    m = Mxy(i,j) .* Mz(k);
    nz = (i <= j) & (m ~= 0);
    MXYZ = [MXYZ; [i(nz),j(nz),k(nz),round(1./m(nz))]];
end

function m = Mxy( i, j )
% Integral of x^i*y^j over the canonical triangle.

    m = Cxy(i,j+1)./(j+1);
end

function c = Cxy( i, j )
% Integral of x^i*(1-x)^j over [0,1].

    c = 1./((i+j+1) .* comball([i+j,j]));
end

function c = comball(v)
    c = zeros(size(v,1),1);
    for i=1:length(c)
        c(i) = comb(v(i,1),v(i,2));
    end
end

function c = comb(n,i)
% Calculate number of unordered subsets of i things from n.

    if (i < 0) || (i > n)
        c = 0;
    else
        if i > n/2
            i = n-i;
        end
        c = 1;
        for j=1:i
            c = (c * (n-j+1))/j;
        end
    end
end

function m = Mz( k )
% Integral of z^k over the line [-1 1].

    m = zeros(size(k));
    evens = mod(k,2)==0;
    m(evens) = 2./(k(evens)+1);
end


% Procedures for calculating with polynomials in x, y, z.

function pf = poly_sparse_to_full( ps )
    maxdeg = max( ps(:,1:3), [], 1 );
    pf = zeros( maxdeg+1 );
    for i=1:size(ps,1)
        x = ps(i,1)+1;
        y = ps(i,2)+1;
        z = ps(i,3)+1;
        pf( x, y, z ) = pf( x, y, z ) + ps(i,4);
    end
end

function ns = poly_full_to_sparse( nf )
    nabi = find( nf );
    [nabx,naby,nabz] = ind2sub(size(nf),nabi(:));
    ns = sortrows( [ nabx-1, naby-1, nabz-1, reshape( nf(nabi), [], 1 ) ] );
    if isempty(ns)
        ns = zeros(0,4);
    end
end

function n = trimpolyf( n )
% Eliminate redundant size from a full polynomial.

    zeros = all( all( n==0, 2 ), 3 );
    lastnz = find( ~zeros, 1, 'last' );
    n = n(1:lastnz,:,:);

    zeros = all( all( n==0, 3 ), 1 );
    lastnz = find( ~zeros, 1, 'last' );
    n = n(:,1:lastnz,:);

    zeros = all( all( n==0, 1 ), 2 );
    lastnz = find( ~zeros, 1, 'last' );
    n = n(:,:,1:lastnz);
end

function p = polypack( p )
% Remove redundant elements from p.
    p = poly_full_to_sparse( poly_sparse_to_full( p ) );
    p = p( abs(p(:,4)) > 1e-10, : );
end

function ps = polyprodPS( p, s )
% Multiply polynomial p by scalar s.
    if s==0
        ps = zeros(0,4);
    else
        ps = [ p(:,1:3), p(:,4)*s ];
    end
end

function ps = polyprodSP( s, p )
% Multiply scalar s by polynomial p.
    if abs(s) <= 1e-10
        ps = zeros(0,4);
    else
        ps = [ p(:,1:3), p(:,4)*s ];
    end
end

function nab = polyadd( na, nb )
% Compute the sum of two polynomials.
    if isempty(na)
        nab = nb;
    elseif isempty(nb)
        nab = na;
    else
        sa = max(na(:,1:3),[],1)+1;
        sb = max(nb(:,1:3),[],1)+1;
        nabf = zeros( max(sa,sb) );
        for i=1:size(na,1)
            nabf( na(i,1)+1, na(i,2)+1, na(i,3)+1 ) = na(i,4);
        end
        for i=1:size(nb,1)
            x = nb(i,1)+1;
            y = nb(i,2)+1;
            z = nb(i,3)+1;
            nabf( x, y, z ) = nabf( x, y, z ) + nb(i,4);
        end
        nab = poly_full_to_sparse( nabf );
    end
end

function nab = polydiff( na, nb )
% Compute the difference of two polynomials.
    nab = polyadd( na, polyprodPS( nb, -1 ) );
end

function nab = polyprod( na, nb )
% Compute the product of two polynomials.
    if isempty(na) || isempty(nb)
        nab = zeros(0,4);
    else
        sa = max(na(:,1:3),[],1)+1;
        sb = max(nb(:,1:3),[],1)+1;
        nabf = zeros( sa + sb - 1 );
        for i=1:size(na,1)
            for j=1:size(nb,1)
                x = na(i,1)+nb(j,1)+1;
                y = na(i,2)+nb(j,2)+1;
                z = na(i,3)+nb(j,3)+1;
                nabf( x, y, z ) = nabf( x, y, z ) + na(i,4)*nb(j,4);
            end
        end
        nab = poly_full_to_sparse( nabf );
    end
end

function mab = polymatadd( ma, mb )
% Add two matrices of polynomials.  ma and mb are 2D cell arrays of
% polynomials.

    A = size(ma,1);
    B = size(ma,2);
    C = size(mb,1);
    D = size(mb,2);
    if (A~=C) || (B ~= D)
        error( 'polymatadd:badsize', 'Cell matrices not identical: %d by %d times %d by %d.', ...
            A, B, C, D );
        return;
    end
    mab = cell(A,B);
    for i=1:A
        for j=1:B;
            mab{i,j} = ma{i,j} + mb{i,j};
        end
    end
end

function mab = polymatprod( ma, mb )
% Multiply two matrices of polynomials.  ma and mb are 2D cell arrays of
% polynomials.

    A = size(ma,1);
    B = size(ma,2);
    C = size(mb,1);
    D = size(mb,2);
    if B ~= C
        error( 'polymatprod:badsize', 'Cell matrices not compatible: %d by %d times %d by %d.', ...
            A, B, C, D );
        return;
    end
    mab = cell(A,D);
    for i=1:A
        for j=1:D;
            for k=1:C
                mab{i,j} = polyadd( mab{i,j}, polyprod( ma{i,k}, mb{k,j} ) );
            end
        end
    end
end

function result = integratePoly( p, J )
    if size(J,1)==6
        J = isoparJacobian( J );
    end
    pJ = polyprod( p, J );
    result = dot( Mxyz( pJ(:,1), pJ(:,2), pJ(:,3) ), pJ(:,4) );
end

function gp = polygrad( p, J )
    if nargin < 2
        % gradient with respect to isopar coords
        gp = cell(3,1);
        for j=1:3
            result = zeros( size(p,1)*3, 4 );
            ri = 0;
            for i=1:size(p,1)
                if p(i,j) > 0
                    ri = ri+1;
                    result( ri, : ) = p(i,:);
                    result( ri, j ) = p(i,j) - 1;
                    result( ri, 4 ) = result( ri, 4 ) * p(i,j);
                end
            end
            gp{j} = polypack(result);
        end
    else
        if size(J,1)==6
            J = isoparJacobian( J );
        end
        gp1 = polygrad(p);
        gp = polymatprod( J, gp1 );
    end



end

function N = isoparShapeFunctions()
    N = {
        [1 0 0 1/2; 1 0 1 -1/2], ...
        [0 1 0 1/2; 0 1 1 -1/2], ...
        [0 0 0 1/2; 1 0 0 -1/2; 0 1 0 -1/2;
         0 0 1 -1/2; 1 0 1 1/2; 0 1 1 1/2], ...
        [1 0 0 1/2; 1 0 1 1/2], ...
        [0 1 0 1/2; 0 1 1 1/2], ...
        [0 0 0 1/2; 1 0 0 -1/2; 0 1 0 -1/2;
         0 0 1 1/2; 1 0 1 -1/2; 0 1 1 -1/2] };
end

function ip = isoparcoords( N, vxs )
% Find the real coordinates from the isoparametric coordinates.

    ip = cell(1,3);
    for i=1:3
        p = zeros(0,4);
        for j=1:length(N)
            p = polyadd( p, polyprodPS( N{j}, vxs(j,i) ) );
        end
        ip{i} = p;
    end
end

function J = fullJacobian( N, vxs )
    J = cell(3,3);
    ip = isoparcoords( N, vxs );
    for i=1:3
        J(:,i) = polygrad( ip{i} );
    end
end
         
function D = polydet( J )
% Compute the determinant of the 3*3 matrix of polynomials.

    D1 = polyprod( J{1,1}, polydiff( polyprod(J{2,2}, J{3,3}), polyprod(J{2,3}, J{3,2}) ) )
    D2 = polyprod( J{1,2}, polydiff( polyprod(J{2,3}, J{3,1}), polyprod(J{2,1}, J{3,3}) ) )
    D3 = polyprod( J{1,3}, polydiff( polyprod(J{2,1}, J{3,2}), polyprod(J{2,2}, J{3,1}) ) )
    D = polyadd( D1, polyadd( D2, D3 ) );

    D1A = polyprod( J{2,1}, polydiff( polyprod(J{3,2}, J{1,3}), polyprod(J{3,3}, J{1,2}) ) );
    D2A = polyprod( J{2,2}, polydiff( polyprod(J{3,3}, J{1,1}), polyprod(J{3,1}, J{1,3}) ) );
    D3A = polyprod( J{2,3}, polydiff( polyprod(J{3,1}, J{1,2}), polyprod(J{3,2}, J{1,1}) ) );
    DA = polyadd( D1, polyadd( D2, D3 ) );
    Derr = DA-D
end

function isp = integrateShapeProds( vxs )
    N = isoparShapeFunctions();
    J = fullJacobian( N, vxs );
    D = polydet( J );
    isp = zeros(6,6);
    for i=1:6
        for j=i:6
            Nij = polyprod( N{i}, N{j} );
            isp(i,j) = integratePoly( Nij, D );
            if j>i
                isp(j,i) = isp(i,j);
            end
        end
    end
end

function isgp = integrateShapeGradientProds( vxs )
    N = isoparShapeFunctions();
    gradN = cell(6,3);
    J = fullJacobian( N, vxs );
    D = polydet( J );
    for i=1:6
        gradN(i,:) = polygrad(N{i},J)';
    end
    gNgN = polymatprod( gradN, gradN' );
    isgp = zeros(6,6);
    for i=1:6
        for j=1:6
            isgp(i,j) = integratePoly( gNgN{i,j}, D );
        end
    end
end
