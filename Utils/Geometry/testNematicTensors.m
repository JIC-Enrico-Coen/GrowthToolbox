function testNematicTensors()

% Find the distribution of anisotropy for the sum of a random set of
% one-directional nematic tensors.

    numBatches = 2000;
    numPerBatch = 3;
    theta = rand( numPerBatch, numBatches ) * (2*pi);
    c = cos(theta);
    s = sin(theta);
    r = randn( numPerBatch, numBatches );
    nt = zeros( 2, 2, numBatches );
    for bi=1:numBatches
        nt(:,:,bi) = vecToNematic( [ r(:,bi).*c(:,bi), r(:,bi).*s(:,bi) ] );
    end
    nos = nematicOrders( nt );







    v = rand(1,3);
    nt = vecToNematic( v );
    
    % Test that nt is invariant under rotation about v.
    r = axisAngle2RotMat( v, rand(1)*2*pi );
    ntr = r * nt * r';
    
    err = max(max(abs(nt-ntr)))
    
    
    stretch = 2;
    
    
    N = 8000;
    noiseLevel = 0.5;
    theta = linspace( 0, pi, N+1 )';
    dtheta = theta(end)/N;
    theta(end) = [];
    theta = theta + (2*rand(N,1)-1)*(dtheta*noiseLevel);
%     theta = (2*rand(N,1)-1)*(dtheta*noiseLevel);
    v = [ stretch * cos(theta), sin(theta) ];
    nt = sumVecsToNematic( v )
    [eigvecs,eigvals] = eig(nt);
    eigvals = diag(eigvals)'
    dims = size(nt,1);
    A = (dims/sqrt(dims-1)) * std(eigvals,1)/norm(eigvals)
    
    v = randOnSphere( N );
    nt = sumVecsToNematic( v )
    dims = size(nt,1);
    
    [eigvecs,eigvals] = eig(nt);
    eigvals = diag(eigvals)'
    
    A = (3/sqrt(2)) * std(eigvals,1)/norm(eigvals)
    
    
    ntstretched = sumVecsToNematic( v.* [stretch 1 1] )
    dims = size(ntstretched,1);
    
    [eigvecs,eigvals] = eig(ntstretched);
    eigvals = diag(eigvals)'
    
    A = (dims/sqrt(dims-1)) * std(eigvals,1)/norm(eigvals)
    
    ntstretched = sumVecsToNematic( diag([stretch 1 1]) )
    dims = size(ntstretched,1);
    
    [eigvecs,eigvals] = eig(ntstretched);
    eigvals = diag(eigvals)'
    
    A = (dims/sqrt(dims-1)) * std(eigvals,1)/norm(eigvals)
end
