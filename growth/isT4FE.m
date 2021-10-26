function ok = isT4FE( fe )
    if isa( fe, 'FiniteElementType' )
        ok = ~isempty( regexp( fe.name, '^S3-D1-', 'once' ) );
    elseif isfield( fe, 'numsimplexdims' )
        ok = (fe.numsimplexdims==3) && (fe.elementDegree==1);
    else
        ok = false;
    end
end
