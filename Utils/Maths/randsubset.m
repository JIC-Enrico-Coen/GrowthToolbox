function s = randsubset( n, k )
% Return a random subset of k of the numbers from 1 to n.
% s will be an array of booleans the same size as n, with k randonly
% selected elements set to true.
%
% This is guaranteed to give exactly k numbers.  If what you need is for
% each number to be chosen independently with probability k/n, just use
% s = rand(1,n) < k/n. 

% fprintf( 1, '%s( %d, %d )\n', mfilename(), n, k );

    k = int32(k);
    if k <= 0
        s = false(1,n);
    elseif k >= n
        s = true(1,n);
    elseif k==1
        s = false(1,n);
        s( randi( [1, n] ) ) = true;
    elseif k==2
        s = false(1,n);
        x = randi( [1, n] );
        y = randi( [1, n-1] );
        if y==x, y = x+1; end
        s( x ) = true;
        s( y ) = true;
    else
        p = double(k)/double(n);
        s = rand(1,n) < p;
        numchosen = sum(s);
        correction = numchosen - k;
        if correction > 0
            s1 = randsubset( numchosen, correction );
            x = find( s );
            s(x(s1)) = false;
        elseif correction < 0
            s1 = randsubset( n - numchosen, -correction );
            x = find( ~s );
            s(x(s1)) = true;
        end
    end
%     if sum(s) ~= k
%         fprintf( 1, '%s: %d of %d asked, %d found.\n', mfilename(), k, n, sum(s) );
%     end
end
