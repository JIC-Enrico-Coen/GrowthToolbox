function iscyclic = cyclicAngles( angles )
%iscyclic = cyclicAngles( angles )
%   ANGLES is an N*K array of angles covering a range of less than 2pi.
%   This procedure returns an N*1 vector of booleans specifying for each
%   row whether the angles in the row are ordered anticlockwise.
%
%   The array can be "ragged", that is, in each row some number of elements
%   can be NaN.  These elements will be ignored.  They can occur anywhere
%   in the row.  If a row consists entirely of NaNs the corresponding
%   element of iscyclic will be true.

    iscyclic = false(size(angles,1),1);
    [~, minai] = min( angles, [], 2 );
    for i=1:size(angles,1)
        rotrow = angles(i, [minai(i):end, 1:(minai(i)-1)]);
        rotrow = rotrow(~isnan(rotrow));
        iscyclic(i) = all(rotrow(1:(end-1)) <= rotrow(2:end));
    end
end
