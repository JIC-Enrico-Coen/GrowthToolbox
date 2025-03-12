function [oldvxindexes,splitfaces] = splitSharedVertexes( faces )
    numfaces = size(faces,1);
    maxnumvxs = size(faces,2);
    facesx = reshape( faces', [], 1 );
    realcorners = ~isnan(facesx);
    numcorners = sum( realcorners );
    oldvxindexes = facesx( realcorners );
    facesx( realcorners ) = (1:numcorners)';
    splitfaces = reshape( facesx', maxnumvxs, numfaces )';
end
