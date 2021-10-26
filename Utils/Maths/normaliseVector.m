function v = normaliseVector( v )
    ns = sqrt( sum( v.*v, 2 ) );
    nz = ns > 0;
    nsnz = ns(nz);
    v(nz,:) = v(nz,:)./repmat( nsnz(:), 1, size(v,2) );
%     for i=1:size(v,1)
%         if nsqs(i) > 0
%         	v(i,:) = v(i,:)/sqrt(nsqs(i));
%         end
%     end
end

