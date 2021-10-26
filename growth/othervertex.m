function pi3 = othervertex(m,ci,pi1,pi2)
    for i=1:3
        trypi = m.tricellvxs(ci,i);
        if (trypi ~= pi1) && (trypi ~= pi2)
            pi3 = trypi;
            break;
        end
    end
    
    % Is this faster?  Cf. otherof3.
%     vxs = m.tricellvxs(ci,:);
%     if vxs(1)==pi1
%         if vxs(2)==pi2
%             pi3 = 3;
%         else
%             pi3 = 2;
%         end
%     elseif vxs(1)==pi2
%         if vxs(2)==pi1
%             pi3 = 3;
%         else
%             pi3 = 2;
%         end
%     else
%         pi3 = 1;
%     end
end
