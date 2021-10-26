function edgelist = maketristrip( pts1, pts2 )
% Result will be a list of pairs (i,j) signifying an edge from pts1(i,:) to pts2(j,:).
    i1 = 1;
    i2 = 1;
    n1 = size( pts1, 1 );
    n2 = size( pts2, 1 );
    edgelist = zeros( n1+n2-1, 2 );
    ne = 1;
    edgelist( 1, : ) = [1 1];
    while true
        if i1==n1
            if i2==n2
                % Finished.
                break;
            else
                i2 = i2+1;
            end
        elseif i2==n2
            i1 = i1+1;
        else
            p11 = pts1(i1,:);
            p12 = pts1(i1+1,:);
            p21 = pts2(i2,:);
            p22 = pts2(i2+1,:);
            d12 = sum( (p22-p11).^2 );
            d21 = sum( (p21-p12).^2 );
            if d12 < d21
                i2 = i2+1;
            else
                i1 = i1+1;
            end
        end
        ne = ne+1;
        edgelist(ne,:) = [ i1, i2 ];
    end
    plotstrip( pts1, pts2, edgelist );
end

function plotstrip( pts1, pts2, edgelist )
    figure(1);
    clf;
    hold on;
    line( pts1(:,1), pts1(:,2) );
    line( pts2(:,1), pts2(:,2) );
    for i=1:size(edgelist,1)
        line( [pts1(edgelist(i,1),1); pts2(edgelist(i,2),1)], ...
              [pts1(edgelist(i,1),2); pts2(edgelist(i,2),2)] );
    end
    hold off;
end
