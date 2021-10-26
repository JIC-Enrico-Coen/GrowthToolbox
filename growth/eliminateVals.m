function remainingVals = eliminateVals( nvals, valsToElim )
%remainingVals = eliminateVals( nvals, valsToElim )
%    Make a list in ascending order of all the integers from 1 to nvals
%    excluding all values in valsToElim.

    remainingVals = 1:nvals;
    remainingVals(valsToElim) = 0;
    remainingVals = find(remainingVals);
  % remainingVals = setdiff( 1:nvals, valsToElim ); % Takes 5 times longer
                                                    % than the above.
end
