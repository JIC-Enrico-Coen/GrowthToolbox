function cm = conductivityMatrix( condVector )
    cm = [ [ condVector(1); condVector(3) ], [ condVector(3); condVector(2) ] ];
end