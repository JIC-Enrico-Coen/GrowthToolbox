function [a,a_each,eigs_each,eigv_each,anisoTensorVec] = anisoMirabet( dirs, wts, dim )
%a = anisoMirabet( dirs )
%   Given a set of directions as a K*N matrix, calculate the measure of
%   anisotropy given by Mirabet et al in
%   https://doi.org/10.1371/journal.pcbi.1006011.
%
%   This measure calculates M = dirs'*dirs/size(dirs,1), and then the
%   eigenvalues of M. For 3 dimensions, anisotropy is then defined as
%
%   A = (3/sqrt(2)) * std(eigs)/norm(eigs)
%
%   It is always between 0 and 1.
%
%   dirs may also be given as a cell array of direction matrices of
%   possibly differing numbers of directions. Anisotropy will be
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
%   * 'unit', to specify that all the directions should be normalised to
%   unit length and combined with equal weight.
%
%   * 'length', to specify that the directions should be weighted according
%   to their lengths.
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
        eigv_each = zeros(size(dirs,1),size(dirs,1),size(dirs,2));
        anisoTensor = zeros( size(dirs,1), 6 ); % Note that this will not work if size(dirs,1) is not 3.
        n_each = zeros(size(dirs));
        if nargin < 3
            dim = size(dirs{i},2);
        end
        for i=1:numel(dirs)
            n_each(i) = size(dirs{i},1);
            if iscell(wts)
                [a_each(i),~,eigs_each(i,:),eigv_each(:,:,i),anisoTensor(:,i)] = anisoMirabet( dirs{i}, wts{i}, dim );
            else
                [a_each(i),~,eigs_each(i,:),eigv_each(:,:,i),anisoTensor(:,i)] = anisoMirabet( dirs{i}, wts, dim );
            end
        end
        good_a_each = isfinite(a_each);
        n_each = n_each(good_a_each);
        a = sum( n_each .* a_each(good_a_each) )/sum( n_each );
    else
        if nargin < 3
            dim = size(dirs,2);
        end
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
        else
            wts = wts( ~baddirs );
        end
        if (numdirs==0) || (sum(wts)==0)
            a = NaN;
        else
            dirs = dirs.*wts(:);
            anisoTensor = dirs' * dirs / sum(wts);
            switch size(dirs,2)
                case 1
                    anisoTensorVec = anisoTensor;
                case 2
                    anisoTensorVec = convert22matrixTo3vector( anisoTensor );
                case 3
                    anisoTensorVec = convert33matrixTo6vector( anisoTensor );
                otherwise
                    anisoTensorVec = [];
            end
            [eigenvectors,ediag] = eigs(anisoTensor,size(anisoTensor,1));
            % The eigenvectors are returned as unit vectors.
            % The eigenvalues are returned in a diagonal matrix in
            % descending order.
            eigenvalues = diag(ediag);
            % anisoTensor is equal to eigenvectors*ediag*eigenvectors'
            % (within rounding error).
            if dim < length(eigenvalues)
                eigenvalues = eigenvalues(1:dim);
            end
            a = (dim/sqrt(dim-1)) * std(eigenvalues,1)/norm(eigenvalues);
        end
        a_each = a;
        eigs_each = eigenvalues(:)';
        eigv_each = eigenvectors;
    end
end
