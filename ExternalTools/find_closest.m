function nearest = find_closest ( dim_num, n, sample_num, s, r, w )

%% FIND_CLOSEST finds the nearest R point to each S point.
%
%  Discussion:
%
%    This routine finds the closest Voronoi cell generator by checking every
%    one.  For problems with many cells, this process can take the bulk
%    of the CPU time.  Other approaches, which group the cell generators into
%    bins, can run faster by a large factor.
%
%  Modified:
%
%    22 October 2004
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, integer DIM_NUM, the spatial dimension.
%
%    Input, integer N, the number of cell generators.
%
%    Input, integer SAMPLE_NUM, the number of sample points.
%
%    Input, real S(DIM_NUM,SAMPLE_NUM), the points to be checked.
%
%    Input, real R(DIM_NUM,N), the cell generators.
%
%    Input, real W(N), weights associated with the cell generators.
%
%    Output, integer NEAREST(SAMPLE_NUM), the index of the nearest cell generators.
%

  if ~exist('w','var')
      w = ones(1,n);
    % w(1:2:n) = 0.2;
  end
  nearest = -ones(1,sample_num);  % Added by RK 2006 Oct 03.
  for js = 1 : sample_num

    distance = Inf;
  % nearest(js) = -1;  % Removed by RK 2006 Oct 03.

    for jr = 1 : n

      if 0  % Conventional wisdom is that built-in operations are faster than
            % explicit loops.  However, this proves not to be the case
            % here, where the explicit loop is an order of magnitude
            % faster than any of these methods.
        rs = r(:,jr) - s(:,js);
        dist_sq = rs'*rs;
      % dist_sq = dot(rs,rs);
      else
          dist_sq = 0.0;
          for i = 1 : dim_num
            dist_sq = dist_sq + ( r(i,jr) - s(i,js) )^2;
          end
          dist_sq = dist_sq * w(jr);
      end

      if ( dist_sq < distance )
        distance = dist_sq;
        nearest(js) = jr;
      end

    end

  end