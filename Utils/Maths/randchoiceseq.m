function r = randchoiceseq( n, k, p, q, d )
%r = randchoiceseq( n, k, p, q, d )
%
%   This procedure generates a series of K members drawn randomly from 1:N,
%   but avoiding "clumps" and "voids".  It will not choose the same number
%   more than once in any P consecutive choices, but will choose every
%   number at least once in every series of Q consecutive choices.
%
%   P defaults to 1, i.e. no constraint on how soon a number can be
%   repeated.  Q defaults to Inf, i.e. no constraint on how long a number
%   can go without being selected.
%
%   D is a distribution over 1:N, by default uniform.  This distribution
%   can be used to set the relative frequency with which each number is
%   chosen in the long term.  D must be positive everywhere.  It need not
%   be normalised.  Note that the relative frequency will never be greater
%   than (N-P)/N, whatever the value of D.
%
%   If a number has gone unchosen for the last Q-1 drawings, it will
%   necessarily be chosen on the next one, regardless of D.
%
%   The resulting sequence is intended to have "no obvious patterns".
%   Ideally, this should say that the distribution of sequences should have
%   maximum entropy subject to P, Q, and D, but we do not have a way of
%   ensuring this.
%
%   The procedure testrandchoiceseq can be used to calculate the
%   distribution of intervals between consecutive occurrences of a number
%   in the sequence.
%
%   See also:
%       testrandchoiceseq

    if (nargin < 3) || isempty(p)
        p = 1;
    end
    if (nargin < 4) || isempty(q)
        q = Inf;
    end
    if nargin < 5
        d = [];
    end
    
    % Silently eliminate invalid arguments.
    p = floor(p);
    q = ceil(q);
    if p < 1, p = 1; end
    if p > n, p = n; end
    if q < n, q = n; end
    if n <= 0
        r = [];
        return;
    end
    
    % Get a random permutation of the set.
    a = randperm(n);
    
    % Dispose of an edge case.
    if k <= p
        % Any randomly selected set of k elements of n satisfies the
        % conditions.
        r = a(1:k);
        return;
    end
    
    % Dispose of another edge case.
    if n <= p
        % The only valid sequence is a repetition of a single randomly
        % chosen permutation of 1:n.
        numreps = floor(n/p);
        rmdr = mod(n,p);
        r = [ repmat( a, 1, numreps ), a(1:rmdr) ];
        return;
    end
    
    % Main algorithm.
    
    % Choose the first P elements of A.
    r = [ a(1:p), zeros(1,k-p) ];
    
    % HISTORY records how long ago each number was last chosen.  For the P
    % that we've just chosen, r(1) was P ago and r(p) was 1 ago.
    % For the remainder, we pretend they were previously chosen at times
    % from P+1 to N, all distinct.  This is not entirely accurate -- the
    % values could be anywhere in the range P+1...Q -- but it will do.
    history(a) = [ p:-1:1, ((p+1):n) ];
    
    for i=(p+1):k
        % See if there's one that we must choose next.
        qi = find( history==q, 1 );
        if isempty(qi)
            % There isn't one we must choose, so choose from
            % those with history >= p.
            eligible = find( history >= p );
            if ~isempty(d)
                de = cumsum( d(eligible) );
                if de(end)==0
                    de(:) = 1/length(de);
                else
                    de = de/de(end);
                end
            end
            if isinf(q)
                if isempty(d)
                    % Choose from a uniform distribution.
                    b = randi( [1,n-p+1] );
                else
                    b = genrand( de, 1 );
                end
            else
                % This distribution is chosen on the basis of heuristic
                % arguments and experimentation.
                weight = 1./(q - history(eligible));
                
                if ~isempty(d)
                    weight = weight .* d(eligible);
                end
                distr = cumsum(weight);
                distr = distr/distr(end);
                b = binsearchupper( distr, rand(1) );
            end
            r(i) = eligible(b);
        else
            % There is one that we must choose.
            r(i) = qi;
        end
        
        % Update the history.  Everything is one time step older, except
        % the one we just chose.
        history = history+1;
        history(r(i)) = 1;
    end
end
