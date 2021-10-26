function rsbp = relScaleBarPos( absSBPosSize, parentAbsSize, margins )
%rsbp = relScaleBarPos( absSBPosSize, parentAbsSize, margins )
%   Calculate the relative position of the scalebar, given its position and
%   size in pixels, the size of the parent in pixels, and the margins in pixels.
%
%   For given values of parentAbsSize, margins, and the scalebar size in
%   pixels, this function and absScaleBarPos should be inverses.
%
%   See also: absScaleBarPos

    movementRange = parentAbsSize - margins([1 3]) - margins([2 4]) - absSBPosSize([3 4]);
    rsbp = (absSBPosSize([1 2]) - margins([1 3]))./movementRange;
end
