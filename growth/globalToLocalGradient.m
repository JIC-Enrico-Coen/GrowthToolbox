function locgrad = globalToLocalGradient( globgrad, trinodes )
%locgrad = globalToLocalGradient( globgrad, trinodes )
%   Compute the barycentric coordinates of the given global vector with
%   respect to the given triangle.

    locgrad =  -globgrad * trinodes';
  % locgrad = locgrad - sum(locgrad)/3;
end
