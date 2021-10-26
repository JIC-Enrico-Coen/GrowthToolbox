function p = frameChangePoints( rot, trans, p )
%

    p = rot*p + trans;
end
