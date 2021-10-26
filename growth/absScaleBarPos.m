function asbp = absScaleBarPos( relpos, absScaleBarSize, parentAbsSize, margins )
%asbp = absScaleBarPos( relpos, absScaleBarSize, parentAbsSize, margins )
%   Calculate the position in pixels of the bottom left corner of the scalebar,
%   given its relative position, the size of the scalebar in pixels, the size
%   of the parent in pixels, and the margins in pixels.
%   margins is [left, right, bottom, top]
%
%   For given values of parentAbsSize, margins, and the scalebar size in
%   pixels, this function and relScaleBarPos should be inverses.
%
%   See also: relScaleBarPos

    movementRange = parentAbsSize - margins([1 3]) - margins([2 4]) - absScaleBarSize;
    asbp = margins([1 3]) + relpos .* movementRange;
end
