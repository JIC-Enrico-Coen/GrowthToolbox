function [newdir,newstart] = randomDirection( ...
            curdir, maxangle, curstart, radius, surfnormal, insurface, parallelprob, N )
% newdir = randomDirection( curstart, radius, curdir, maxangle, surfnormal, insurface, usemaxangle, N )
%   Generate a random direction that deviates by not more than maxangle
%   from currentdir, and which is uniformly distributed over the spherical
%   cap that is the space of all permitted directions.  If surfnormal is
%   supplied, nonempty, and nonzero, limit the new vector to the subset making an
%   angle with surfnormal of more than 90 degrees.
%
%   If maxangle is empty, all directions are permitted, the same as if
%   maxangle were pi or more.
%
%   insurface is a boolean.  If false, the above happens, but if true, the
%   new direction is constrained to lie parallel to the surface, i.e.
%   perpendicular to surfnormal.  (surfnormal must be supplied and nonzero
%   in this case.)  The new direction is randomly uniformly distributed
%   over the range of permitted angles in the surface.
%
%   curdir must be a row vector.
%
%   newdir will be a unit length row vector.
%
%   The default value of N is 1.  A larger value can be supplied to
%   generate any number of random directions as an N*3 matrix.

    if nargin==0
        % Random direction uniformly over a sphere.
        x = 1 - rand(1)*2;
        y = sqrt(1-x.*x);
        phi = rand(1)*2*pi;
        newdir = [ y*cos(phi), y*sin(phi), x ];
        newstart = [ 0 0 0 ];
        return;
    end
    if (nargin < 1) || isempty(curdir)
        curdir = [];
    end
    if (nargin < 2) || isempty(maxangle)
        maxangle = pi;
    end
    if (nargin < 3) || isempty(curstart)
        curstart = [0 0 0];
    end
    if (nargin < 4) || isempty(radius)
        radius = 1;
    end
    if nargin < 5
        surfnormal = [];
    else
        nsf = norm( surfnormal );
        if nsf==0
            surfnormal = [];
        else
            surfnormal = surfnormal/nsf;
        end
    end
    if (nargin < 6) || isempty(insurface) || isempty(surfnormal)
        insurface = false;
    end
    if (nargin < 7)
        parallelprob = [];
    end
    if (nargin < 8) || isempty(N)
        N = 1;
    end
    if N <= 0
        newdir = [];
        newstart = [ 0 0 0 ];
        return;
    end
    usemaxangle = ~isempty( parallelprob );
    NCD = norm(curdir);
    if NCD <= 0
        % Random direction uniformly over a sphere.
        x = 1 - rand(N,1)*2;
        y = sqrt(1-x.*x);
        phi = rand(N,1)*2*pi;
        newdir = [ y.*cos(phi), y.*sin(phi), x ];
        newstart = [ 0 0 0 ];
        return;
    end
    K = curdir/NCD;
    [I,J] = makeframe( K );
    if isempty(surfnormal)
        if usemaxangle
            rn = rand(N,1);
            x = zeros( 1, N );
            x(rn <= parallelprob) = 1 - cos(maxangle);
            x(rn > parallelprob) = 1;
        else
            x = 1 - rand(N,1)*(1 - cos(maxangle));
        end
        y = sqrt(1-x.*x);
        phi = rand(N,1)*2*pi;
        newtransversedir = cos(phi)*I + sin(phi)*J;
        newdir = newtransversedir.*repmat(y,1,size(newtransversedir,2)) + x*K;
        newstart = repmat( curstart, size(newdir,1), 1 ) + newtransversedir*(radius*2);
    else
        newstart = curstart;
        if insurface
            transverse = cross( K, surfnormal );
            along = cross( surfnormal, transverse );
            a = vecangle( curdir, along );
            if a > maxangle
                newdir = [];
            else
                if a+maxangle >= pi
                    maxsurfangle = pi;
                else
                    maxsurfangle = acos( cos(maxangle)/cos(a) );
                end
                if usemaxangle
                    rn = rand(N,1);
                    theta = zeros( 1, N );
                    theta(rn <= parallelprob/2) = maxsurfangle;
                    theta((rn > parallelprob/2) & (rn <= parallelprob)) = -maxsurfangle;
                    theta(rn > parallelprob) = 0;
                else
                    theta = rand(N,1) * (maxsurfangle*2) - maxsurfangle;
                end
                newdir = cos(theta)*along + sin(theta)*transverse;
            end
        else
            newdir = zeros(N,3);
            gotdirs = 0;
            numiters = 0;
            MAXITERS = 20*(log2(N)+1);
            while (gotdirs < N) && (numiters < MAXITERS)
                N1 = N - gotdirs;
                x = 1 - rand(N1,1)*(1 - cos(maxangle));
                y = sqrt(1-x.*x);
                phi = rand(N1,1)*2*pi;
                extradirs = ((cos(phi).*y)*I + (sin(phi).*y)*J) + x*K;
                ok = dot( extradirs, repmat(surfnormal,N1,1), 2 ) < 0;
                extradirs = extradirs(ok,:);
                newdir( (gotdirs+1):(gotdirs+size(extradirs,1)), : ) = extradirs;
                gotdirs = gotdirs+size(extradirs,1);
                numiters = numiters+1;
            end
            newdir( (gotdirs+1):N, : ) = [];
        end
    end
end
