function [a,a_each,eigs_each] = anisoMirabet( dirs, wts )
%a = anisoMirabet( dirs )
%   Given a set of directions as a 3*N matrix, calculate the measure of
%   anisotropy given by Mirabet et al in
%   https://doi.org/10.1371/journal.pcbi.1006011.
%
%   This measure calculates M = dirs'*dirs/size(dirs,1), and then the
%   eigenvalues of M. Anisotropy is then defined as
%
%   A = (3/sqrt(2)) * std(eigs)/norm(eigs)
%
%   It is always between 0 and 1.
%
%   dirs may also be given as a cell array of direction matrices of
%   possibly differing numbers of directions. Anisotripy will be
%   calculated for each one, and returned in A_EACH, and A will be their
%   average, weighted by the numbers of directions.
%
%   Any direction containing infinite or nan values, or which is all zero,
%   is ignored. Remaining directions are normalised to have length 1.
%
%   If there are no remaining directions, A is NaN. When using multiple
%   sets of directions, sets yielding NaN are ignored in calculating the
%   mean anisotropy.
%
%   This is generalised to work in any number of dimensions by using an
%   initial factor dims/sqrt(dims-1).
%
%   It is further generalised to allow weighting of the directions. The wts
%   argument can be:
%
%   * A vector of numerical weights.
%
%   * 'unit', to specify that all the directions should be norlaised to
%   unit length and combined with equal weight.
%
%   * 'length', to specify that the directions should be weighted according
%   to their lengths..
%
%   In each case the weights will be normalised to sum to 1. The default is
%   'unit'.

% Some Matlab gotchas:
%
% 1. To get the actual standard deviation of the eigenvalues, give 1 as the
% second argument to std, otherwise it will divide by dim-1 instead of dim.
%
% 2. By default, eigs() only returns the first six eigenvalues. To get all
% of them, demand them all by giving the number demanded as the second
% argument.

    if nargin < 2
        wts = 'unit';
    end

    if iscell(dirs)
        a_each = zeros(size(dirs));
        eigs_each = zeros(size(dirs));
        n_each = zeros(size(dirs));
        for i=1:numel(dirs)
            n_each(i) = size(dirs{i},1);
            if iscell(wts)
                [a_each(i),~,eigs_each(i,:)] = anisoMirabet( dirs{i}, wts{i} );
            else
                [a_each(i),~,eigs_each(i,:)] = anisoMirabet( dirs{i}, wts );
            end
        end
        good_a_each = isfinite(a_each);
        n_each = n_each(good_a_each);
        a = sum( n_each .* a_each(good_a_each) )/sum( n_each );
    else
        dim = size(dirs,2);
        normdir = sqrt( sum( dirs.^2, 2 ) );
        dirs = dirs ./ normdir;
        baddirs = ~all(isfinite(dirs),2);
        dirs(baddirs,:) = [];
        normdir(baddirs,:) = [];
        numdirs = size(dirs,1);
        if ischar(wts)
            switch wts
                case 'unit'
                    wts = ones(numdirs,1);
                case 'length'
                    wts = normdir(~baddirs);
            end
        end
        if (numdirs==0) || (sum(wts)==0)
            a = NaN;
        else
            dirs = dirs.*wts(:);
            M = dirs' * dirs / sum(wts); %numdirs;
            e = eigs(M,size(M,1));
            a = (dim/sqrt(dim-1)) * std(e,1)/norm(e);
        end
        a_each = a;
        eigs_each = e(:)';
    end
end
