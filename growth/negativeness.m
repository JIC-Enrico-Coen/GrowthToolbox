function w = negativeness( threshold, v )
    negs = v >= threshold;
    w = v;
    w(negs) = -w(negs);
end
