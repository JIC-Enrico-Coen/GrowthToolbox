function oc = oncluster()
% A very crude test to determine if we are running on the cluster.
% Confirmed still working 2021 Aug, on ada.uea.ac.uk.

    oc = contains( userHomeDirectory(), '/gpfs/home/' );
end