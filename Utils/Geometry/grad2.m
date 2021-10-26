function r = grad2(pts)
% This is a continuous transformation of atan2 that is about twice as fast
% to compute.  It returns values in a range from -0.5 to +0.5 varying
% continuously and montonically with atan2(pts).

    numpts = size(pts,1);
    r = zeros(numpts,1);

    for i=1:numpts
        x = pts(i,1);
        y = pts(i,2);
        if y==0
            if x >= 0
                r(i) = 0;
            else
                r(i) = 0.5;
            end
        elseif x==0
            if y >= 0
                r(i) = 0.25;
            else
                r(i) = -0.25;
            end
        elseif y > x
            if y > -x
                % Top edge
                r(i) = 0.25 - x/(y*8);
            else
                % Left edge
                if y >= 0
                    % Upper left
                    r(i) = 0.5 + y/(x*8);
                else
                    % Lower left
                    r(i) = -0.5 + y/(x*8);
                end
            end
        else
            if y > -x
                % Right edge
                r(i) = y/(x*8);
            else
                % Bottom edge
                r(i) = -0.25 - x/(y*8);
            end
        end
    end
    
% The following version is twice as slow.  Vectorisation does not always
% help.
%
%     ax = abs(pts(:,1));
%     ay = abs(pts(:,2));
%     top = pts(:,2) >= ax;
%     r(top) = 0.25 - pts(top,1)./(pts(top,2)*8);
%     bottom = pts(:,2) <= -ax;
%     r(bottom) = -0.25 - pts(bottom,1)./(pts(bottom,2)*8);
%     right = pts(:,1) >= ay;
%     r(right) = pts(right,2)./(pts(right,1)*8);
%     left = pts(:,1) <= -ay;
%     uppery = pts(:,2) >= 0;
%     lefttop = left & uppery;
%     r(lefttop) = 0.5 + pts(lefttop,2)./(pts(lefttop,1)*8);
%     leftbottom = left & ~uppery;
%     r(leftbottom) = -0.5 + pts(leftbottom,2)./(pts(leftbottom,1)*8);
%     return;
end
