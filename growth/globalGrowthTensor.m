function gGT = globalGrowthTensor( frame, perVertexRates )
%gGT = globalGrowthTensor( frame, perVertexRates )
%   frame is a frame of reference, assumed to be an orthonormal matrix.
%   perVertexRates is an N*3 set of growth rates, for example, the values
%   of the three growth morphogens at each vertex of a finite element.
%   The result is a growth tensor per vertex in 6-vector form, in the
%   global frame.

    gGT = zeros( size(perVertexRates,1), 6 );
    for i=1:size(perVertexRates,1)
        gGT(i,:) = uniaxialGrowthTensor6( frame, perVertexRates(i,:)' );
    end
%% From uniaxialGrowthTensor6
%     gt = zeros(1,6);
%     for j=1:size(direction,1)
%         d = direction(j,:);
%         a = d(1);  b = d(2);  c = d(3);
%         gt = gt + [a^2 b^2 c^2 2*b*c 2*c*a 2*a*b];
%     end
end