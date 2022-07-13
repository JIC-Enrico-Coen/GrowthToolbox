function washolding = beginhold( ax )
    washolding = ishold( ax );
    hold( ax, 'on' );
end