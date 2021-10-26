function [ds,ps,as,qs,bs,parallel] = lineLineDistance( p01, q01, wholeLine )
%[ds,ps,as,qs,bs,parallel] = lineLineDistance( p01, q01, wholeLine )
%   p01 and q01 are 2*D arrays, specifying pairs of D-dimensional points.
%   Find the closest point on each of these line segments to the other
%   segment, and the distance between these points. If wholeLine is true (it
%   defaults to false) then the lines are considered as infinite lines.
%
%   The closest points are expressed both as points and as barycentric
%   coordinates, i.e. p = a(1)*p01(1,:) + a(2)*p01(2,:) and
%   q = b(1)*q01(1,:)+b(2)*q01(2,:).
%
%   The five results are row vectors of lengths 1, D, 2, D, and 2.
%
%   p01 and q01 can instead be 2*D*N arrays, and the results will be,
%   respectively, N*1, N*D, N*2, N*D, and N*2 arrays.
%   If N for just one of p01 or q01 is 1, it will be replicated as
%   necessary to match the other.

    if nargin < 3
        wholeLine = false;
    end

    pN = size(p01,3);
    qN = size(q01,3);
    if (pN==1) && (qN > 1)
        p01 = repmat( p01, [1, 1, qN] );
        N = qN;
    elseif (pN > 1) && (qN==1)
        q01 = repmat( q01, [1, 1, pN] );
        N = pN;
    else
        N = pN;
    end
    D = size(p01,2);
    
    ds = zeros(N,1);
    ps = zeros(N,D);
    as = zeros(N,2);
    qs = zeros(N,D);
    bs = zeros(N,2);
    parallel = false;
    
    
    for n = 1:N
        if size(p01,1)==1
            pdiff = [0 0 0];
            psingle = true;
        else
            pdiff = p01(2,:,n)-p01(1,:,n);
            psingle = all( abs(pdiff) <= 1e-10 );
        end
        if size(q01,1)==1
            qdiff = [0 0 0];
            qsingle = true;
        else
            qdiff = q01(2,:,n)-q01(1,:,n);
            qsingle = all( abs(qdiff) <= 1e-10 );
        end
        
        if psingle
            p = p01(1,:,n);
            a = [1,0];
            if qsingle
                q = q01(1,:,n);
                d = sqrt(sum((p-q).^2,2));
                b = [1,0];
            else
                [d,q,b] = pointLineDistance( q01(:,:,n), p, wholeLine );
            end
        elseif qsingle
            q = q01(1,:,n);
            b = [1,0];
            [d,p,a] = pointLineDistance( p01(:,:,n), q, wholeLine );
        else
            X = [pdiff;qdiff]*[pdiff',qdiff'];
            if cond(X) > 10000
                % Line segments are parallel.
                if wholeLine
                    a = [1,0];
                    p = p01(1,:,n);
                    [d,q,b] = pointLineDistance( q01(:,:,n), p, true );
                else
                    parallel = true;
                    [dq0,p0,a0] = pointLineDistance( p01(:,:,n), q01(1,:,n), true );
                    [dq1,p1,a1] = pointLineDistance( p01(:,:,n), q01(2,:,n), true );
                    [xx,perm] = sort([a0(2),a1(2),0,1]);
                    strperm = sprintf( '%d%d%d%d', perm );
                    switch strperm
                        case '1234'
                            d = norm( p01(1,:,n)-q01(2,:,n) );
                            a = 1;
                            b = 0;
                        case '2134'
                            d = norm( p01(1,:,n)-q01(1,:,n) );
                            a = 1;
                            b = 1;
                        case '3412'
                            d = norm( p01(2,:,n)-q01(1,:,n) );
                            a = 0;
                            b = 1;
                        case '3421'
                            d = norm( p01(2,:,n)-q01(2,:,n) );
                            a = 0;
                            b = 0;
                        case '1324'
                            d = dq1;
                            a = 1 - a1(2)/2;
                            b = a1(2)/(2*(a1(2)-a0(2)));
                        case '2314'
                            d = dq0;
                            a = 1 - a0(2)/2;
                            b = 1 - a0(2)/(2*(a0(2)-a1(2)));
                        case '3142'
                            d = dq0;
                            a = (1-a0(2))/2;
                            b = (a1(2)-(1-a))/(a1(2)-a0(2));
                        case '3241'
                            d = dq1;
                            a = (1-a1(2))/2;
                            b = (a1(2)-(1-a))/(a1(2)-a0(2));
                        case '3124'
                            d = pointLineDistance( q01(:,:,n), p01(1,:,n), false );
                            a = (1-a1(2))/(1-a1(2)+a0(2));
                            b = a;
                        case '3214'
                            d = pointLineDistance( q01(:,:,n), p01(1,:,n), false );
                            a = (1-a0(2))/(1-a0(2)+a1(2));
                            b = 1-a;
                        case '1342'
                            d = dq0;
                            a = (a1(2)-1)/(a1(2)-1-a0(2));
                            b = a;
                        case '2341'
                            d = dq0;
                            a = (a0(2)-1)/(a0(2)-1-a1(2));
                            b = 1-a;
                        otherwise
                            error( '%s: Unexpected point ordering %s.\n', mfilename(), strperm );
                    end
                    a = [a,1-a];
                    b = [b,1-b];
                    p = a(1)*p01(1,:,n) + a(2)*p01(2,:,n);
                    q = b(1)*q01(1,:,n) + b(2)*q01(2,:,n);
                end
            else
                % This is the calculation of the barycentric coords of the
                % nearest points on the two lines to each other. This is
                % the only substantial geometry in this procedure;
                % everything else is just handling of special cases.
                r = p01(1,:,n)-q01(1,:,n);
                Y = -[pdiff;qdiff]*r';
                V = X\Y;
                a1 = V(1);
                b1 = -V(2);
                
                % Validity check
%                 xp = p01(1,:)*(1-a1) + p01(2,:)*a1;
%                 xq = q01(1,:)*(1-b1) + q01(2,:)*b1;
%                 xtrav = xq-xp;
%                 % xtrav should be perpendicular to both line segments.
%                 dotp = dot(xtrav,pdiff)
%                 dotq = dot(xtrav,qdiff)
%                 if (abs(dotp) > 0.001) || (abs(dotq) > 0.001)
%                     warning('%s', mfilename() );
%                     xxxx = 1;
%                 end

                if wholeLine
                    a = [1-a1,a1];
                    b = [1-b1,b1];
                    p = p01(1,:,n) + a1 * pdiff;
                    q = q01(1,:,n) + b1 * qdiff;
                    d = sqrt(sum((p-q).^2,2));
                else
                    % Now we go through all the special cases required in order
                    % to limit the calculation to just the line segments
                    % instead of the whole of the infinite lines.
                    if a1 >= 1
                        % We're past the 1 end of p01.
                        a0 = 0; a1 = 1;
                        p = p01(2,:,n);
                        p_end = true;
                    elseif a1 <= 0
                        % We're past the 0 end of p01.
                        a0 = 1; a1 = 0;
                        p = p01(1,:,n);
                        p_end = true;
                    else
                        % We're somewhere in the middle of p01.
                        a0 = 1-a1;
                        p = p01(1,:,n) + a1 * pdiff;
                        p_end = false;
                    end
                    if b1 >= 1
                        % We're past the 1 end of q01.
                        b0 = 0; b1 = 1;
                        q = q01(2,:,n);
                        q_end = true;
                    elseif b1 <= 0
                        % We're past the 0 end of q01.
                        b0 = 1; b1 = 0;
                        q = q01(1,:,n);
                        q_end = true;
                    else
                        % We're somewhere in the middle of q01.
                        b0 = 1-b1;
                        q = q01(1,:,n) + b1 * qdiff;
                        q_end = false;
                    end
                    a = [a0,a1];
                    b = [b0,b1];
                    if p_end
                        if q_end
                            % The intersection lies off the end of both lines.
                            % This does not imply that those ends are the
                            % nearest points on the two line segments to each
                            % other.  There are four other possibilities that
                            % we must test.
                            d = sqrt(sum((p-q).^2,2));
                            [dq0p,pq0,aq0] = pointLineDistance( p01(:,:,n), q01(1,:,n), false );
                            [dq1p,pq1,aq1] = pointLineDistance( p01(:,:,n), q01(2,:,n), false );
                            [dp0q,qp0,bp0] = pointLineDistance( q01(:,:,n), p01(1,:,n), false );
                            [dp1q,qp1,bp1] = pointLineDistance( q01(:,:,n), p01(2,:,n), false );
                            [d,whichdi] = min( [ dq0p,dq1p,dp0q,dp1q,d ] );
                            switch whichdi
                                case 1
                                    p = pq0;
                                    q = q01(1,:,n);
                                    a = aq0;
                                    b = [1 0];
                                case 2
                                    p = pq1;
                                    q = q01(2,:,n);
                                    a = aq1;
                                    b = [0 1];
                                case 3
                                    q = qp0;
                                    p = p01(1,:,n);
                                    a = [1 0];
                                    b = bp0;
                                case 4
                                    q = qp1;
                                    p = p01(2,:,n);
                                    a = [0 1];
                                    b = bp1;
                                otherwise % case 5
                                    % No correction required.
                            end
                        else
                            [d,q,b] = pointLineDistance( q01(:,:,n), p, false );
                        end
                    elseif q_end
                        [d,p,a] = pointLineDistance( p01(:,:,n), q, false );
                    else
                        d = sqrt(sum((p-q).^2,2));
                    end
                end
            end
        end
    
        ds(n) = d;
        ps(n,:) = p;
        as(n,:) = a;
        qs(n,:) = q;
        bs(n,:) = b;
    end
end
