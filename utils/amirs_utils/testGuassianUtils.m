fprintf('[INFO] starting Guassian Utils test...');
utils = guassianUtils;
% a = rand(25,25) - mean(mean(rand(25,25)));
% a = randn(25,25);
% a = rand(100,100) - mean(mean(rand(100,100)));
% a = [...
%   0,1,0,0,0; ...
%   0,1,0,0,0; ...
%   0,1,0,0,1; ...
%   1,1,1,1,1; ...
%   0,0,0,0,0];
% a = [...
%   0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0; ...
%   1,1,1,1,1,1,1,1,1,1; ...
%   1,1,1,1,1,1,1,1,1,1; ...
%   0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0];
% a = [...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ...
%   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
d = size(a,1);
[mu_y, mu_x, covariance] = utils.fit2DGaussian(a);
sample = utils.drawSamplesFrom2DGaussian(mu_y, mu_x, covariance, d);
fprintf('Done!\n');
samplen = sample ./ normalization_factor;
kernel = sign(randn(d,d)) .* (randn(d,d)+10*samplen);

normalization_factor = max(sample(:));
samplen = sample ./ normalization_factor;
disp(sample)
tmp = randn(d,d);
kernel = (tmp / max(abs(tmp(:))) + sign(randn(d,d)) .* samplen) * normalization_factor;
disp(kernel)
figure; mesh(1:1:d, 1:1:d, kernel);


% oneD = load('W1-layer-1.mat');
% twoD = load('/Users/amirhk/dev/data/cifar-alexnet/+8epoch-random-from-baseline-1D/W1-layer-1.mat');

% t = [];
% for i = 1:96
%   meanOneD = mean(mean(oneD.W1(:,:,1,i)));
%   meanTwoD = mean(mean(twoD.W1(:,:,1,i)));
%   fprintf('mean 1D: %f, mean 2D: %f\n', meanOneD, meanTwoD);
%   t(end + 1) = meanOneD - meanTwoD;
% end

% mean(t) % should be 0!
