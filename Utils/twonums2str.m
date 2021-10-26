function s = twonums2str( n )
    if length(n)==1
        s = num2str(n(1));
    else
        s = [ num2str(n(1)), ' - ', num2str(n(2)) ];
    end
end

