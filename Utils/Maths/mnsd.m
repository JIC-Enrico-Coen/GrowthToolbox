function [mn,sd] = mnsd( xx, yy )
%[mn,sd] = mnsd( xx, yy )
%   Find the mean and standard deviation for the points xx, yy.

    dx = xx(2:end)-xx(1:(end-1));
    avy = (yy(2:end)+yy(1:(end-1)))/2;
    total = sum(dx .* avy);
    yx = yy.*xx;
    avyx = (yx(2:end)+yx(1:(end-1)))/2;
    mn = sum(dx .* avyx)/total;
    yxx = yy.*(xx.^2);
    avyxx = (yxx(2:end)+yxx(1:(end-1)))/2;
    sd = sqrt(sum(dx .* avyxx)/(total))
    
    return;
    
    
    dy = yy(2:end)-yy(1:(end-1));
    xx3 = xx.^3;
    dx3 = (xx3(2:end)-xx3(1:(end-1)))/3;
    xx4 = xx.^4;
    dx4 = (xx4(2:end)-xx4(1:(end-1)))/4;
    
    sd1 = sqrt(sum( dx4.*dy./dx ...
               + dx3.*(yy(1:(end-1)).*xx(2:end) - yy(2:end).*xx(1:(end-1)))./dx ))
end

