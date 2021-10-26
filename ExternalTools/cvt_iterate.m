function [ r, seed, it_diff, energy, count, cellaxis, centroids, celleigs ] = ...
    cvt_iterate ( dim_num, n, batch, sample, initialize, ...
                  sample_per_gen, seed, r, amount, usertype, ...
                  varargin )

%% CVT_ITERATE takes one step of the CVT iteration.
%
%  Discussion:
%
%    The routine is given a set of points, called "generators", which
%    define a tessellation of the region into Voronoi cells.  Each point
%    defines a cell.  Each cell, in turn, has a centroid, but it is
%    unlikely that the centroid and the generator coincide.
%
%    Each time this CVT iteration is carried out, an attempt is made
%    to modify the generators in such a way that they are closer and
%    closer to being the centroids of the Voronoi cells they generate.
%
%    A large number of sample points are generated, and the nearest generator
%    is determined.  A count is kept of how many points were nearest to each
%    generator.  Once the sampling is completed, the location of all the
%    generators is adjusted.  This step should decrease the discrepancy
%    between the generators and the centroids.
%
%    The centroidal Voronoi tessellation minimizes the "energy",
%    defined to be the integral, over the region, of the square of
%    the distance between each point in the region and its nearest generator.
%    The sampling technique supplies a discrete estimate of this
%    energy.
%
%  Modified:
%
%    19 November 2004
%
%  Author:
%
%    John Burkardt
%
%  Reference:
%
%    Qiang Du, Vance Faber, and Max Gunzburger,
%    Centroidal Voronoi Tessellations: Applications and Algorithms,
%    SIAM Review, Volume 41, 1999, pages 637-676.
%
%  Parameters:
%
%    Input, integer DIM_NUM, the spatial dimension.
%
%    Input, integer N, the number of Voronoi cells.
%
%    Input, integer BATCH, sets the maximum number of sample points
%    generated at one time.  It is inefficient to generate the sample
%    points 1 at a time, but memory intensive to generate them all
%    at once.  You might set BATCH to min ( SAMPLE_PER_GEN*N, 10000 ), for instance.
%    BATCH must be at least 1.
%
%    Input, integer SAMPLE, specifies how the sampling is done.
%    -1, 'RAND', using MATLAB's RAND function;
%     0, 'UNIFORM', using a simple uniform RNG;
%     1, 'HALTON', from a Halton sequence;
%     2, 'GRID', points from a grid;
%     3, 'USER', refers to the USER routine;
%
%    Input, logical INITIALIZE, is TRUE if the SEED must be reset to SEED_INIT
%    before computation.  Also, the pseudorandom process may need to be
%    reinitialized.
%
%    Input, integer SAMPLE_PER_GEN, the number of sample points per generator.
%
%    Input, integer SEED, the random number seed.
%
%    Input, real R(DIM_NUM,N), the Voronoi cell generators.
%
%    Input, real AMOUNT, the proportion of distance towards the centroid to
%    move.  0 = no movement, 1 = original algorithm.  Added by RK.
%
%    Input, string USERTYPE, and all subsequent arguments, extra
%    information to be supplied to user() (only used if SAMPLE==3).
%    Defaults to the empty string and no further arguments.
%    Added by RK 2006 Oct 02.
%
%    Output, real R(DIM_NUM,N), the updated Voronoi cell generators.
%
%    Output, integer SEED, the updated random number seed.
%
%    Output, real IT_DIFF, the L2 norm of the difference
%    between the iterates.
%
%    Output, real ENERGY, the discrete "energy", divided
%    by the number of sample points.
%
%    Output, real COUNT(N), the number of points in each cell.
%
%    Output, real CELLAXIS(N,DIM_NUM), the longest axis of each Voronoi
%    cell.
%
%    Output, real CENTROID(N,DIM_NUM), the centroid of each Voronoi
%    cell.
%
%    Output, real CELLEIGS(N,2), the maximum and minimum eigenvalues of
%    the covariance matrix of each Voronoi cell.
%
%    Output, real CELLCOV(N,DIM_NUM,DIM_NUM), the covariance matrix
%    of each Voronoi cell.  (Not currently computed.)

%
%  Take each generator as the first sample point for its region.
%  This can slightly slow the convergence, but it simplifies the
%  algorithm by guaranteeing that no region is completely missed
%  by the sampling.
%

  if ~exist('usertype','var')
      usertype = [];
  end
  wantCellaxis = nargout >= 6;
  wantCentroids = nargout >= 7;
  wantCelleigs = nargout >= 8;
  % if nargin < 9, usertype = ''; end
  sample_num = sample_per_gen * n;

  energy = 0.0;
  r2(1:dim_num,1:n) = r(1:dim_num,1:n);
  count(1:n) = 1;
%  r2 = zeros(dim_num,n);
%  count = zeros(1,n);
%
%  Generate the sampling points S in batches.
%
  have = 0;
  if wantCellaxis
      distribPts = zeros( dim_num, ceil(2*min ( sample_num , batch )/n), n );
      distribCount = zeros( 1, n );
  end

  while ( have < sample_num )

    get = min ( sample_num - have, batch );

    [ s, seed ] = cvt_sample ( dim_num, sample_num, get, sample, initialize, ...
      seed, usertype, varargin{:} );
  
    initialize = 0;
%
%  Find the index N of the nearest cell generator to each sample point S.
%
    nearest = find_closest ( dim_num, n, get, s, r );
%
%  Add S to the centroid associated with generator N.
%
    for j = 1 : get
      nj = nearest(j);
      r2(1:dim_num,nj) = r2(1:dim_num,nj) + s(1:dim_num,j);
      energy = energy + sum ( ( r(1:dim_num,nj) - s(1:dim_num,j) ).^2 );
      if (have==0) && wantCellaxis
          distribCount(nj) = distribCount(nj)+1;
          distribPts( :, distribCount(nj), nj ) = s(:,j);
      end
      count(nj) = count(nj) + 1;
    end
    

    have = have + get;
  end
  
  if wantCellaxis
      cellaxis = zeros( n, dim_num );
      cellcov = zeros( n, dim_num, dim_num );
      for ci = 1:n
        if distribCount(ci) > 0
            [V, S] = eig(cov(distribPts(:,1:distribCount(ci),ci)'));
            [Y,I] = max(diag(S));
            cellaxis(ci,:) = V(:,I);
          % cellcov(ci,:,:) = V;
            if wantCelleigs
                celleigs(ci,:) = [ Y, min(diag(S)) ];
            end
        end
      end
  end

  
% if amount <= 0, return; end
% Even if amount is zero, we still need to do the calculation in order to
% obtain estimates of the sizes of the cells.
  
%
%  Estimate the centroids.
%
% Modified by RK 2006 October.
% Weight the generators an amount depending on the area of the cell (as
% estimated by count(j)).  The weights must all be positive.
    if 1
      % Original version: generator is counted once.
        r2(1:dim_num,1:n) = r2(1:dim_num,1:n) + r(1:dim_num,1:n);
        count = count + 1;
        for j = 1 : n
            r2(1:dim_num,j) = r2(1:dim_num,j) / count(j);
        end
    else
      % Modified version: generator is counted enough times to give all cells the
      % same total number of points.
        avPtsPerCell = sample_num/n;
        k = 1;
        centreWeight = (k*avPtsPerCell + max(count)) - count;
        for j = 1 : n
            r2(1:dim_num,j) = (r2(1:dim_num,j) + centreWeight(j)*r(1:dim_num,j)) / ...
                              (count(j) + centreWeight(j));
        end
    end
% End of code modified by RK.

%
%  Determine the sum of the distances between generators and centroids.
%
  it_diff = 0.0;
  for j = 1 : n
    it_diff = it_diff + sqrt ( sum ( ( r2(1:dim_num,j) - r(1:dim_num,j) ).^2 ) );
  end
%
%  Replace the generators by the centroids.
%
  if amount==1
      r(1:dim_num,1:n) = r2(1:dim_num,1:n);
  elseif amount==0
      % Nothing.
  else
      r(1:dim_num,1:n) = amount * r2(1:dim_num,1:n) + (1-amount) * r(1:dim_num,1:n);
  end
%
%  Normalize the discrete energy estimate.
%
  energy = energy / sample_num;
  if wantCentroids
      centroids = [ r2', zeros( size(r2,2), 1 ) ];
  end
