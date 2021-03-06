% -------------------------------------------------------------------------
function fh = networkInitializationUtils()
% -------------------------------------------------------------------------
% Copyright (c) 2017, Amir-Hossein Karimi
% All rights reserved.

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

  % assign function handles so we can call these local functions from elsewhere
  fh.convLayer = @convLayer;
  fh.loadWeights = @loadWeights;
  fh.constructConvLayer = @constructConvLayer;
  fh.reluLayer = @reluLayer;
  fh.avrLayer = @avrLayer;
  fh.tanhLayer = @tanhLayer;
  fh.sigmoidLayer = @sigmoidLayer;
  fh.flattenLayer = @flattenLayer;
  fh.poolingLayer2by2 = @poolingLayer2by2;
  fh.poolingLayerAlexNet = @poolingLayerAlexNet;
  fh.poolingLayerLeNetAvg = @poolingLayerLeNetAvg;
  fh.poolingLayerLeNetMax = @poolingLayerLeNetMax;
  fh.poolingLayerLeNetMaxNonDecimated = @poolingLayerLeNetMaxNonDecimated;
  fh.poolingLayerSpecial = @poolingLayerSpecial;
  fh.dropoutLayer = @dropoutLayer;
  fh.bnormLayer = @bnormLayer;
  fh.softmaxlossLayer = @softmaxlossLayer;
  fh.nnlossLayer = @nnlossLayer;

  % fh.getConvLayerIndices = @poolingLayer;
  % fh.createBottleneckLayersFromSingleConvLayer = @poolingLayer;

% --------------------------------------------------------------------
function structuredLayer = convLayer(dataset, network_arch, layer_number, k, m, n, init_multiplier, pad, weight_init_type, weight_init_source);
% --------------------------------------------------------------------
  switch weight_init_source
    case 'load'
      layerWeights = loadWeights(dataset, network_arch, layer_number, weight_init_type);
    case 'gen'
      switch weight_init_type

        case 'testing'
          layerWeights{1} = init_multiplier * ones(k, k, m, n, 'single');
          layerWeights{2} = zeros(1, n, 'single');

        case 'identity'
          layerWeights{1} = ones(k, k, m, n, 'single');
          layerWeights{2} = zeros(1, n, 'single');
        case 'random-between-pm-one'
          layerWeights{1} = rand(k, k, m, n, 'single') * 2 - 1;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian'
          layerWeights{1} = init_multiplier * randn(k, k, m, n, 'single');
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3'
          filter_width = 3;
          gaussian_filter = fspecial('gaussian', [filter_width, filter_width], 1);
          gaussian_random_kernels = init_multiplier * randn(k, k, m, n, 'single');
          smoothed_gaussian_random_kernels = imfilter(gaussian_random_kernels, gaussian_filter);
          layerWeights{1} = smoothed_gaussian_random_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-4'
          filter_width = 4;
          gaussian_filter = fspecial('gaussian', [filter_width, filter_width], 1);
          gaussian_random_kernels = init_multiplier * randn(k, k, m, n, 'single');
          smoothed_gaussian_random_kernels = imfilter(gaussian_random_kernels, gaussian_filter);
          layerWeights{1} = smoothed_gaussian_random_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling'
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling-ScaleUp-3'
          scale_times = 3;
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma * scale_times, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling-ScaleDown-3'
          scale_times = 1/3;
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma * scale_times, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling-ScaleDown-10'
          scale_times = 1/10;
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma * scale_times, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling-ScaleDown-100'
          scale_times = 1/100;
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma * scale_times, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling-ScaleDown-1000'
          scale_times = 1/1000;
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma * scale_times, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling-ScaleDown-10000'
          scale_times = 1/10000;
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma * scale_times, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling-ScaleDown-100000'
          scale_times = 1/100000;
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma * scale_times, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-Cov-Sampling-TEST'
          filter_width = 3;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernelTEST(k, filter_width, init_multiplier);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          % layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{1} = reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-4-Cov-Sampling'
          filter_width = 4;
          [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
          % mu = zeros(k * k, 1);
          generated_samples = mvnrnd(mu, sigma, m * n);
          % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
          layerWeights{1} = init_multiplier * reshape(generated_samples', k, k, m, n);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianAnisoDiffed-2'
          gaussian_random_kernels = init_multiplier * randn(k, k, m, n, 'single');
          % confirmed... this runs on every 2D plane separately (on 3D and 4D matrices)
          anisodiffed_gaussian_random_kernels = anisodiff2D(gaussian_random_kernels, 2, 1/7, 30, 2);
          layerWeights{1} = single(anisodiffed_gaussian_random_kernels);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianAnisoDiffed-4'
          gaussian_random_kernels = init_multiplier * randn(k, k, m, n, 'single');
          % confirmed... this runs on every 2D plane separately (on 3D and 4D matrices)
          anisodiffed_gaussian_random_kernels = anisodiff2D(gaussian_random_kernels, 4, 1/7, 30, 2);
          layerWeights{1} = single(anisodiffed_gaussian_random_kernels);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianAnisoDiffed-6'
          gaussian_random_kernels = init_multiplier * randn(k, k, m, n, 'single');
          % confirmed... this runs on every 2D plane separately (on 3D and 4D matrices)
          anisodiffed_gaussian_random_kernels = anisodiff2D(gaussian_random_kernels, 6, 1/7, 30, 2);
          layerWeights{1} = single(anisodiffed_gaussian_random_kernels);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianAnisoDiffed-8'
          gaussian_random_kernels = init_multiplier * randn(k, k, m, n, 'single');
          % confirmed... this runs on every 2D plane separately (on 3D and 4D matrices)
          anisodiffed_gaussian_random_kernels = anisodiff2D(gaussian_random_kernels, 8, 1/7, 30, 2);
          layerWeights{1} = single(anisodiffed_gaussian_random_kernels);
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-mult2DGaussian'
          tmp_kernels = zeros(k, k, m, n, 'single');
          for j = 1:n
            for i = 1:m
              random_std = rand() * 3;
              tmp = gen2DGaussianFilter(k, random_std);
              tmp_kernels(:,:,i,j) = tmp;
            end
          end
          layerWeights{1} = init_multiplier * randn(k, k, m, n, 'single');
          layerWeights{1} = layerWeights{1} .* tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianSmoothed-3-mult2DGaussian'
          tmp_kernels = zeros(k, k, m, n, 'single');
          for j = 1:n
            for i = 1:m
              random_std = rand() * 3;
              tmp = gen2DGaussianFilter(k, random_std);
              tmp_kernels(:,:,i,j) = tmp;
            end
          end
          filter_width = 3;
          gaussian_filter = fspecial('gaussian', [filter_width, filter_width], 1);
          gaussian_random_kernels = init_multiplier * randn(k, k, m, n, 'single');
          smoothed_gaussian_random_kernels = imfilter(gaussian_random_kernels, gaussian_filter);
          layerWeights{1} = smoothed_gaussian_random_kernels;
          layerWeights{1} = layerWeights{1} .* tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussianAnisoDiffed-2-mult2DGaussian'
          tmp_kernels = zeros(k, k, m, n, 'single');
          for j = 1:n
            for i = 1:m
              random_std = rand() * 3;
              tmp = gen2DGaussianFilter(k, random_std);
              tmp_kernels(:,:,i,j) = tmp;
            end
          end
          filter_width = 3;
          gaussian_filter = fspecial('gaussian', [filter_width, filter_width], 1);
          gaussian_random_kernels = init_multiplier * randn(k, k, m, n, 'single');
          % confirmed... this runs on every 2D plane separately (on 3D and 4D matrices)
          anisodiffed_gaussian_random_kernels = anisodiff2D(gaussian_random_kernels, 2, 1/7, 30, 2);
          layerWeights{1} = single(anisodiffed_gaussian_random_kernels);
          layerWeights{1} = layerWeights{1} .* tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');







% ------------------------------------------------------------------------------------------

        case 'gaussian-IdentityCovariance-MuDivide-1-SigmaDivide-1'
          % layerWeights{1} = tmp_kernels;
          % layerWeights{1} = tmp_kernels / sqrt(n);
          % tmp_kernels = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 1);
          % layerWeights{1} = init_multiplier * tmp_kernels;
          % layerWeights{1} = init_multiplier * randn(k, k, m, n, 'single');
          % layerWeights{1} = ones(k, k, m, n, 'single');
          % layerWeights{1} = randn(k, k, m, n, 'single') / 10000;
          % layerWeights{1} = randn(k, k, m, n, 'single') / 100;
          layerWeights{1} = randn(k, k, m, n, 'single');
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-IdentityCovariance-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-IdentityCovariance-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 100);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-IdentityCovariance-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 1000);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-IdentityCovariance-MuDivide-1-SigmaDivide-10000'
          tmp_kernels = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 10000);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-IdentityCovariance-MuDivide-1-SigmaDivide-100000'
          tmp_kernels = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 100000);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'gaussian-SmoothedCovariance-2-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1, 2);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-2-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10, 2);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-2-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100, 2);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-2-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1000, 2);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-2-MuDivide-1-SigmaDivide-10000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10000, 2);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-2-MuDivide-1-SigmaDivide-100000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100000, 2);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'gaussian-SmoothedCovariance-3-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1, 3);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-3-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10, 3);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-3-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100, 3);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-3-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1000, 3);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-3-MuDivide-1-SigmaDivide-10000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10000, 3);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-3-MuDivide-1-SigmaDivide-100000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100000, 3);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'gaussian-SmoothedCovariance-4-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1, 4);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-4-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10, 4);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-4-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100, 4);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-4-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1000, 4);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-4-MuDivide-1-SigmaDivide-10000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10000, 4);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-4-MuDivide-1-SigmaDivide-100000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100000, 4);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'gaussian-SmoothedCovariance-5-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1, 5);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-5-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10, 5);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-5-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100, 5);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-5-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1000, 5);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-5-MuDivide-1-SigmaDivide-10000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10000, 5);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-SmoothedCovariance-5-MuDivide-1-SigmaDivide-100000'
          tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100000, 5);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'gaussian-MixedSmoothedCovariance-MuDivide-1-SigmaDivide-1'
          tmp_kernels_1 = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 1);
          tmp_kernels_2 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1, 2);
          tmp_kernels_3 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1, 3);
          tmp_kernels_4 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1, 4);
          tmp_kernels_5 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1, 5);
          tmp_kernels = zeros(size(tmp_kernels_1));
          for i = 1:m
            for j = 1:n
              switch ceil(rand() * 5)
                case 1
                  tmp_kernels(:,:,i,j) = tmp_kernels_1(:,:,i,j);
                case 2
                  tmp_kernels(:,:,i,j) = tmp_kernels_2(:,:,i,j);
                case 3
                  tmp_kernels(:,:,i,j) = tmp_kernels_3(:,:,i,j);
                case 4
                  tmp_kernels(:,:,i,j) = tmp_kernels_4(:,:,i,j);
                case 5
                  tmp_kernels(:,:,i,j) = tmp_kernels_5(:,:,i,j);
              end
            end
          end
          tmp_kernels = single(tmp_kernels);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-MixedSmoothedCovariance-MuDivide-1-SigmaDivide-10'
          tmp_kernels_1 = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 10);
          tmp_kernels_2 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10, 2);
          tmp_kernels_3 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10, 3);
          tmp_kernels_4 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10, 4);
          tmp_kernels_5 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 10, 5);
          tmp_kernels = zeros(size(tmp_kernels_1));
          for i = 1:m
            for j = 1:n
              switch ceil(rand() * 5)
                case 1
                  tmp_kernels(:,:,i,j) = tmp_kernels_1(:,:,i,j);
                case 2
                  tmp_kernels(:,:,i,j) = tmp_kernels_2(:,:,i,j);
                case 3
                  tmp_kernels(:,:,i,j) = tmp_kernels_3(:,:,i,j);
                case 4
                  tmp_kernels(:,:,i,j) = tmp_kernels_4(:,:,i,j);
                case 5
                  tmp_kernels(:,:,i,j) = tmp_kernels_5(:,:,i,j);
              end
            end
          end
          tmp_kernels = single(tmp_kernels);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-MixedSmoothedCovariance-MuDivide-1-SigmaDivide-100'
          tmp_kernels_1 = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 100);
          tmp_kernels_2 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100, 2);
          tmp_kernels_3 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100, 3);
          tmp_kernels_4 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100, 4);
          tmp_kernels_5 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 100, 5);
          tmp_kernels = zeros(size(tmp_kernels_1));
          for i = 1:m
            for j = 1:n
              switch ceil(rand() * 5)
                case 1
                  tmp_kernels(:,:,i,j) = tmp_kernels_1(:,:,i,j);
                case 2
                  tmp_kernels(:,:,i,j) = tmp_kernels_2(:,:,i,j);
                case 3
                  tmp_kernels(:,:,i,j) = tmp_kernels_3(:,:,i,j);
                case 4
                  tmp_kernels(:,:,i,j) = tmp_kernels_4(:,:,i,j);
                case 5
                  tmp_kernels(:,:,i,j) = tmp_kernels_5(:,:,i,j);
              end
            end
          end
          tmp_kernels = single(tmp_kernels);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-MixedSmoothedCovariance-MuDivide-1-SigmaDivide-1000'
          tmp_kernels_1 = getGaussianKernelsWithIdentityCovariance(k, m, n, 1, 1000);
          tmp_kernels_2 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1000, 2);
          tmp_kernels_3 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1000, 3);
          tmp_kernels_4 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1000, 4);
          tmp_kernels_5 = getGaussianKernelsWithSmoothedCovariance(k, m, n, 1, 1000, 5);
          tmp_kernels = zeros(size(tmp_kernels_1));
          for i = 1:m
            for j = 1:n
              switch ceil(rand() * 5)
                case 1
                  tmp_kernels(:,:,i,j) = tmp_kernels_1(:,:,i,j);
                case 2
                  tmp_kernels(:,:,i,j) = tmp_kernels_2(:,:,i,j);
                case 3
                  tmp_kernels(:,:,i,j) = tmp_kernels_3(:,:,i,j);
                case 4
                  tmp_kernels(:,:,i,j) = tmp_kernels_4(:,:,i,j);
                case 5
                  tmp_kernels(:,:,i,j) = tmp_kernels_5(:,:,i,j);
              end
            end
          end
          tmp_kernels = single(tmp_kernels);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');






% ------------------------------------------------------------------------------------------

        case 'gaussian-CentreSurroundCovariance-randomDivide-1000-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 1, 1000);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-1000-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 10, 1000);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-1000-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 100, 1000);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-1000-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 1000, 1000);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'gaussian-CentreSurroundCovariance-randomDivide-100-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 1, 30);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-100-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 10, 100);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-100-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 100, 100);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-100-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 1000, 100);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'gaussian-CentreSurroundCovariance-randomDivide-10-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 1, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-10-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 10, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-10-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 100, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-10-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 1000, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'gaussian-CentreSurroundCovariance-randomDivide-1-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 1, 1);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-1-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 10, 1);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-1-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 100, 1);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian-CentreSurroundCovariance-randomDivide-1-MuDivide-1-SigmaDivide-1000'
          tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, 1, 1000, 1);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');





















% ------------------------------------------------------------------------------------------

        case 'mixedKernels-IdentityCovariance-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getMixedKernelsWithIdentityCovariance(k, m, n, 1, 1);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'mixedKernels-IdentityCovariance-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getMixedKernelsWithIdentityCovariance(k, m, n, 1, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'mixedKernels-IdentityCovariance-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getMixedKernelsWithIdentityCovariance(k, m, n, 1, 100);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');


        case 'mixedKernels-IdentityCovariance-MuDivide-10-SigmaDivide-1'
          tmp_kernels = getMixedKernelsWithIdentityCovariance(k, m, n, 10, 1);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'mixedKernels-IdentityCovariance-MuDivide-10-SigmaDivide-10'
          tmp_kernels = getMixedKernelsWithIdentityCovariance(k, m, n, 10, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'mixedKernels-IdentityCovariance-MuDivide-10-SigmaDivide-100'
          tmp_kernels = getMixedKernelsWithIdentityCovariance(k, m, n, 10, 100);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'mixedKernels-SmoothedCovariance-3-MuDivide-1-SigmaDivide-1'
          tmp_kernels = getMixedKernelsWithSmoothedCovariance(k, m, n, 1, 1);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'mixedKernels-SmoothedCovariance-3-MuDivide-1-SigmaDivide-10'
          tmp_kernels = getMixedKernelsWithSmoothedCovariance(k, m, n, 1, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'mixedKernels-SmoothedCovariance-3-MuDivide-1-SigmaDivide-100'
          tmp_kernels = getMixedKernelsWithSmoothedCovariance(k, m, n, 1, 100);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');


        case 'mixedKernels-SmoothedCovariance-3-MuDivide-10-SigmaDivide-1'
          tmp_kernels = getMixedKernelsWithSmoothedCovariance(k, m, n, 10, 1);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'mixedKernels-SmoothedCovariance-3-MuDivide-10-SigmaDivide-10'
          tmp_kernels = getMixedKernelsWithSmoothedCovariance(k, m, n, 10, 10);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'mixedKernels-SmoothedCovariance-3-MuDivide-10-SigmaDivide-100'
          tmp_kernels = getMixedKernelsWithSmoothedCovariance(k, m, n, 10, 100);
          layerWeights{1} = init_multiplier * tmp_kernels;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------

        case 'logNormal-layer5-ratVisualCortex'
          lognormal_mean = -0.702;
          lognormal_var = 0.9355;
          mu = log( (lognormal_mean ^ 2) / sqrt(lognormal_var + lognormal_mean ^ 2));
          sigma = sqrt( log( lognormal_var / (lognormal_mean ^ 2) + 1));
          generated_samples = lognrnd(mu, sigma, 1, k * k * m * n);
          generated_samples = generated_samples .* sign(randn(size(generated_samples)));
          % randomly make these values positive and negative
          tmp_kernels = single(reshape(generated_samples', k, k, m, n));
          layerWeights{1} = init_multiplier * tmp_kernels * 0.1;
          layerWeights{2} = zeros(1, n, 'single');

% ------------------------------------------------------------------------------------------


        case 'bernoulli'
          random_kernels = randn(k, k, m, n, 'single');
          tmp = init_multiplier * (random_kernels < 0); % < 0 because randn()
          bernoulli_random_kernels = single(tmp .* sign(randn(size(tmp))));
          layerWeights{1} = bernoulli_random_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'bernoulliSmoothed-3'
          filter_width = 3;
          gaussian_filter = fspecial('gaussian', [filter_width, filter_width], 1);
          random_kernels = randn(k, k, m, n, 'single');
          tmp = init_multiplier * (random_kernels < 0); % < 0 because randn()
          bernoulli_random_kernels = single(tmp .* sign(randn(size(tmp))));
          smoothed_bernoulli_random_kernels = imfilter(bernoulli_random_kernels, gaussian_filter);
          layerWeights{1} = smoothed_bernoulli_random_kernels;
          layerWeights{2} = zeros(1, n, 'single');
        case 'bernoulliAnisoDiffed-2'
          % filter_width = 3;
          % gaussian_filter = fspecial('gaussian', [filter_width, filter_width], 1);
          random_kernels = randn(k, k, m, n, 'single');
          tmp = init_multiplier * (random_kernels < 0); % < 0 because randn()
          bernoulli_random_kernels = single(tmp .* sign(randn(size(tmp))));
          % confirmed... this runs on every 2D plane separately (on 3D and 4D matrices)
          anisodiffed_bernoulli_random_kernels = anisodiff2D(bernoulli_random_kernels, 2, 1/7, 30, 2);
          layerWeights{1} = single(anisodiffed_bernoulli_random_kernels);
          layerWeights{2} = zeros(1, n, 'single');


        case 'gaussian2D'
          kernels = zeros(k, k, m, n, 'single');
          for j = 1:n
            for i = 1:m
              random_std = rand() * 3;
              tmp = gen2DGaussianFilter(k, random_std);
              kernels(:,:,i,j) = tmp;
            end
          end
          layerWeights{1} = kernels * init_multiplier * 10; % x 10 because I feel it shouldn't get toooo small
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian2DMeanSubtracted'
          kernels = zeros(k, k, m, n, 'single');
          for j = 1:n
            for i = 1:m
              random_std = rand() * 3;
              tmp = gen2DGaussianFilter(k, random_std);
              tmp = tmp - mean(tmp(:));
              kernels(:,:,i,j) = tmp;
            end
          end
          layerWeights{1} = kernels * init_multiplier * 10; % x 10 because I feel it shouldn't get toooo small
          layerWeights{2} = zeros(1, n, 'single');
        case 'gaussian2DMeanSubtractedRandomlyFlipped'
          kernels = zeros(k, k, m, n, 'single');
          for j = 1:n
            for i = 1:m
              random_std = rand() * 3;
              tmp = gen2DGaussianFilter(k, random_std);
              tmp = tmp - mean(tmp(:));
              kernels(:,:,i,j) = tmp;
            end
            % WARNING... you want to possibly flip each kernel with all its channels (not each channel of each kernel, and not all kernels together)
            kernels(:,:,:,j) = kernels(:,:,:,j) * sign(randn());
          end
          layerWeights{1} = kernels * init_multiplier * 10; % x 10 because I feel it shouldn't get toooo small
          layerWeights{2} = zeros(1, n, 'single');


        % case 'quasiRandSobol'
        %   q = sobolset(1);
        %   q = scramble(q, 'MatousekAffineOwen');
        %   tmp = net(q, k * k * m * n) .* sign(randn(k * k * m * n, 1));
        %   layerWeights{1} = single(init_multiplier * reshape(tmp, [k, k, m, n]));
        %   layerWeights{2} = zeros(1, n, 'single');
        case 'quasiRandSobolSkip'
          q = sobolset(1, 'Skip', 1e3, 'Leap', 1e2);
          q = scramble(q, 'MatousekAffineOwen');
          tmp = net(q, k * k * m * n) .* sign(randn(k * k * m * n, 1));
          layerWeights{1} = single(init_multiplier * reshape(tmp, [k, k, m, n]));
          % disp(mean(mean(mean(mean(layerWeights{1})))));
          % layerWeights{1}
          % keyboard
          layerWeights{2} = zeros(1, n, 'single');
        otherwise
          throwException('[ERROR] Generating non-gaussian weights not supported from this code.');
      end
  end
  structuredLayer = constructConvLayer(network_arch, layer_number, layerWeights, pad, weight_init_type, weight_init_source);

% --------------------------------------------------------------------
function weights = loadWeights(dataset, network_arch, layer_number, weight_init_type)
% --------------------------------------------------------------------
  fprintf( ...
    '[INFO] Loading %s weights (layer %d) from saved directory...\t', ...
    weight_init_type, ...
    layer_number);
  dev_path = getDevPath();

  % sub_dir_path = fullfile('data', 'cifar-alexnet', sprintf('w_%s', weight_init_type));
  % TODO: search subtstring... if network_arch starts with 'alexnet' use the 'alexnet' folder
  sub_dir_path = fullfile( ...
    'data', ...
    'generated_weights', ...
    sprintf('%s', network_arch), ...
    sprintf('w-%s', weight_init_type));
  file_name_suffix = sprintf('-layer-%d.mat', layer_number);
  tmp = load(fullfile(dev_path, sub_dir_path, sprintf('W1%s', file_name_suffix)));
  weights{1} = tmp.W1;
  tmp = load(fullfile(dev_path, sub_dir_path, sprintf('W2%s', file_name_suffix)));
  weights{2} = tmp.W2;
  fprintf('Done!\n');

% --------------------------------------------------------------------
function structuredLayer = constructConvLayer(network_arch, layer_number, weights, pad, weight_init_type, weight_init_source)
% --------------------------------------------------------------------
  lr = [.1 2];
  if strcmp(network_arch, 'alexnet') && layer_number == 18
    lr = lr * .1;
  elseif strcmp(network_arch, 'lenet') && layer_number == 12
  end
  structuredLayer = struct( ...
    'type', 'conv', ...
    'name', sprintf('conv%s-%s-%s', layer_number, weight_init_type, weight_init_source), ...
    'weights', {weights}, ...
    'learning_rate', lr, ...
    'stride', 3, ...
    'pad', pad);

% --------------------------------------------------------------------
function structuredLayer = reluLayer(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'relu', ...
    'name', sprintf('relu%d', layer_number));

% --------------------------------------------------------------------
function structuredLayer = sigmoidLayer(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'sigmoid', ...
    'name', sprintf('sigmoid%d', layer_number));

% --------------------------------------------------------------------
function structuredLayer = avrLayer(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'avr', ...
    'name', sprintf('avr%d', layer_number));

% --------------------------------------------------------------------
function structuredLayer = tanhLayer(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'tanh', ...
    'name', sprintf('tanh%d', layer_number));

% --------------------------------------------------------------------
function structuredLayer = flattenLayer(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'flatten', ...
    'name', sprintf('flatten%d', layer_number));

% --------------------------------------------------------------------
function structuredLayer = poolingLayer2by2(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'pool', ...
    'name', sprintf('pool_%s', layer_number), ...
    'method', 'max', ...
    'pool', [2 2], ...
    'stride', 2, ...
    'pad', 0); % Emulate caffe_n

% --------------------------------------------------------------------
function structuredLayer = poolingLayerAlexNet(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'pool', ...
    'name', sprintf('pool_%s', layer_number), ...
    'method', 'max', ...
    'pool', [3 3], ...
    'stride', 2, ...
    'pad', [0 1 0 1]); % Emulate caffe_n

% --------------------------------------------------------------------
function structuredLayer = poolingLayerLeNetAvg(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'pool', ...
    'name', sprintf('pool_%s', layer_number), ...
    'method', 'avg', ...
    'pool', [3 3], ...
    'stride', 2, ...
    'pad', [0 1 0 1]); % Emulate caffe_n

% --------------------------------------------------------------------
function structuredLayer = poolingLayerLeNetMax(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'pool', ...
    'name', sprintf('pool_%s', layer_number), ...
    'method', 'max', ...
    'pool', [3 3], ...
    'stride', 2, ...
    'pad', [0 1 0 1]); % Emulate caffe_n

% --------------------------------------------------------------------
function structuredLayer = poolingLayerLeNetMaxNonDecimated(layer_number)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'pool', ...
    'name', sprintf('pool_%s', layer_number), ...
    'method', 'max', ...
    'pool', [3 3], ...
    'stride', 1, ...
    'pad', [0 2 0 2]); % Emulate caffe_n

% --------------------------------------------------------------------
function structuredLayer = poolingLayerSpecial(layer_number, method, pool, stride, pad)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'pool', ...
    'name', sprintf('pool_%s', layer_number), ...
    'method', method, ...
    'pool', pool, ...
    'stride', stride, ...
    'pad', pad); % Emulate caffe_n


% --------------------------------------------------------------------
function structuredLayer = dropoutLayer(layer_number, dropout_ratio)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'dropout', ...
    'name', sprintf('dropout%s', layer_number), ...
    'rate', dropout_ratio);

% --------------------------------------------------------------------
function structuredLayer = bnormLayer(layer_number, ndim)
% --------------------------------------------------------------------
  structuredLayer = struct( ...
    'type', 'bnorm', ...
    'weights', {{ones(ndim, 1, 'single'), zeros(ndim, 1, 'single')}}, ...
    'learningRate', [1 1], ...
    'weightDecay', [0 0]);

% --------------------------------------------------------------------
function structuredLayer = softmaxlossLayer()
% --------------------------------------------------------------------
  structuredLayer = struct('type', 'softmaxloss');

% --------------------------------------------------------------------
function structuredLayer = nnlossLayer()
% --------------------------------------------------------------------
  structuredLayer = struct('type', 'loss');
  % structuredLayer = struct('type', 'loss', 'jigar', 'tala');

% --------------------------------------------------------------------
function [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
% --------------------------------------------------------------------
  large_number = 100000;
  gaussian_filter = fspecial('gaussian', [filter_width, filter_width], 1);
  gaussian_random_kernels = randn(k, k, large_number, 'single');
  smoothed_gaussian_random_kernels = imfilter(gaussian_random_kernels, gaussian_filter);
  % note the transpose at the end of the line below!! reshape(..., [large_number, k * k]) is WRONG!
  vectorized = reshape(smoothed_gaussian_random_kernels, [k * k, large_number])';

  % mean matrix (matricized)
  mu = mean(vectorized);
  % tmp = reshape(mean(vectorized), [k, k]);

  % cov matrix
  sigma = cov(vectorized);
  % keyboard

% % --------------------------------------------------------------------
% function [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernelTEST(k, filter_width, init_multiplier);
% % --------------------------------------------------------------------
%   large_number = 100000;
%   gaussian_filter = fspecial('gaussian', [filter_width, filter_width], 1);
%   gaussian_random_kernels = init_multiplier * randn(k, k, large_number, 'single');
%   smoothed_gaussian_random_kernels = imfilter(gaussian_random_kernels, gaussian_filter);
%   % note the transpose at the end of the line below!! reshape(..., [large_number, k * k]) is WRONG!
%   vectorized = reshape(smoothed_gaussian_random_kernels, [k * k, large_number])';

%   % mean matrix (matricized)
%   mu = mean(vectorized);
%   % tmp = reshape(mean(vectorized), [k, k]);

%   % cov matrix
%   sigma = cov(vectorized);
%   % keyboard

% --------------------------------------------------------------------
function filter = get5x5PrewittHoriz()
% --------------------------------------------------------------------
  filter = [2,2,2,2,2;1,1,1,1,1;0,0,0,0,0;-1,-1,-1,-1,-1;-2,-2,-2,-2,-2];


% --------------------------------------------------------------------
function filter = get5x5PrewittVert()
% --------------------------------------------------------------------
  filter = [2,2,2,2,2;1,1,1,1,1;0,0,0,0,0;-1,-1,-1,-1,-1;-2,-2,-2,-2,-2];
  filter = fliplr(filter)';


% --------------------------------------------------------------------
function filter = get5x5SobelVert()
% --------------------------------------------------------------------
  filter = [2, 1, 0, -1, -2;
            3, 2, 0, -2, -3;
            4, 3, 0, -3, -4;
            3, 2, 0, -2, -3;
            2, 1, 0, -1, -2];

% --------------------------------------------------------------------
function filter = get5x5SobelHoriz()
% --------------------------------------------------------------------
  filter = get5x5PrewittVert()';


% --------------------------------------------------------------------
function tmp_kernels = getMixedKernelsWithIdentityCovariance(k, m, n, mu_divider, sigma_divider)
% --------------------------------------------------------------------
  mu = zeros(1, k * k);
  sigma = eye(k * k);
  tmp_kernels = getMixedKernelsHelper(k, m, n, mu, sigma, mu_divider, sigma_divider);


% --------------------------------------------------------------------
function tmp_kernels = getMixedKernelsWithSmoothedCovariance(k, m, n, mu_divider, sigma_divider)
% --------------------------------------------------------------------
  filter_width = 3;
  [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
  tmp_kernels = getMixedKernelsHelper(k, m, n, mu, sigma, mu_divider, sigma_divider);


% --------------------------------------------------------------------
function tmp_kernels = getMixedKernelsHelper(k, m, n, mu, sigma, mu_divider, sigma_divider)
% --------------------------------------------------------------------
  tmp_kernels = zeros(k, k, m, n, 'single');
  for j = 1:n
    for i = 1:m
      % randomly choose a kernel class to use as mu
      % switch ceil(rand() * 5)
      %   case 1
      %     mu = mu + 0;
      %     % sigma = sigma / sigma_divider / 100;
      %     sigma = sigma / sigma_divider / 1;
      %   case 2
      %     mu = mu + reshape(get5x5PrewittHoriz(), 1, k * k); % mu must be row vector
      %     sigma = sigma / sigma_divider / 1;
      %   case 3
      %     mu = mu + reshape(get5x5PrewittVert(), 1, k * k); % mu must be row vector
      %     sigma = sigma / sigma_divider / 1;
      %   case 4
      %     mu = mu + reshape(get5x5SobelVert(), 1, k * k); % mu must be row vector
      %     sigma = sigma / sigma_divider / 1;
      %   case 5
      %     mu = mu + reshape(get5x5SobelHoriz(), 1, k * k); % mu must be row vector
      %     sigma = sigma / sigma_divider / 1;
      % end
      switch ceil(rand() * 8)
        case 1
          mu = mu + 0;
          % sigma = sigma / sigma_divider / 100;
          sigma = sigma / sigma_divider / 1;
        case 2
          mu = mu + 0;
          % sigma = sigma / sigma_divider / 100;
          sigma = sigma / sigma_divider / 1;
        case 3
          mu = mu + 0;
          % sigma = sigma / sigma_divider / 100;
          sigma = sigma / sigma_divider / 1;
        case 4
          mu = mu + 0;
          % sigma = sigma / sigma_divider / 100;
          sigma = sigma / sigma_divider / 1;
        case 5
          mu = mu + reshape(get5x5PrewittHoriz(), 1, k * k); % mu must be row vector
          sigma = sigma / sigma_divider / 1;
        case 6
          mu = mu + reshape(get5x5PrewittVert(), 1, k * k); % mu must be row vector
          sigma = sigma / sigma_divider / 1;
        case 7
          mu = mu + reshape(get5x5SobelVert(), 1, k * k); % mu must be row vector
          sigma = sigma / sigma_divider / 1;
        case 8
          mu = mu + reshape(get5x5SobelHoriz(), 1, k * k); % mu must be row vector
          sigma = sigma / sigma_divider / 1;
      end
      mu = mu / mu_divider;
      single_generated_kernel = mvnrnd(mu, sigma,1);
      tmp_kernels(:,:,i,j) = reshape(single_generated_kernel, k, k);
      % random_std = rand() * 3;
      % tmp = gen2DGaussianFilter(k, random_std);
      % tmp_kernels(:,:,i,j) = tmp;
    end
  end

% --------------------------------------------------------------------
function tmp_kernels = getGaussianKernelsWithIdentityCovariance(k, m, n, mu_divider, sigma_divider)
% --------------------------------------------------------------------
  mu = zeros(1, k * k);
  sigma = eye(k * k);
  tmp_kernels = getGaussianKernelsHelper(k, m, n, mu, sigma, mu_divider, sigma_divider);

% --------------------------------------------------------------------
function tmp_kernels = getGaussianKernelsWithSmoothedCovariance(k, m, n, mu_divider, sigma_divider, filter_width)
% --------------------------------------------------------------------
  % filter_width = 3;
  [mu, sigma] = getMeanVectorAndCovarianceMatrixOfSmoothedKernel(k, filter_width);
  tmp_kernels = getGaussianKernelsHelper(k, m, n, mu, sigma, mu_divider, sigma_divider);

% --------------------------------------------------------------------
function tmp_kernels = getGaussianKernelsHelper(k, m, n, mu, sigma, mu_divider, sigma_divider)
% --------------------------------------------------------------------
  % keyboard
  % mu = mu / mu_divider;
  % d = size(sigma, 1);
  % sigma_mask = ones(d) - eye(d) + eye(d) * 1 / sigma_divider;
  % sigma = sigma .* sigma_mask;

  mu = mu / mu_divider;
  sigma = sigma / sigma_divider;
  generated_samples = mvnrnd(mu, sigma, m * n);
  % need the transpose below so each of the generated samples gets reshaped into it's own k x k surface
  tmp_kernels = single(reshape(generated_samples', k, k, m, n));



% --------------------------------------------------------------------
function tmp_kernels = getGaussianKernelsWithCentreSurroundCovariance(k, m, n, mu_divider, sigma_divider, additive_random_divider)
% --------------------------------------------------------------------
  large_number = 100000;
  vectorized = zeros(large_number, k * k);
  for i = 1 : large_number
    g1 = gen2DGaussianFilter(k,1);
    g2 = g1 - mean(g1(:));
    g3 = g2 * sign(randn());
    g4 = g3 + randn(k,k) / additive_random_divider;
    vectorized(i,:) = reshape(g4, 1, k * k);
  end

  mu = mean(vectorized);
  sigma = cov(vectorized);

  tmp_kernels = getGaussianKernelsHelper(k, m, n, mu, sigma, mu_divider, sigma_divider);




% % --------------------------------------------------------------------
% function conv_layer_indices = getConvLayerIndices(net)
% % --------------------------------------------------------------------
%   conv_layer_indices = [];
%   for i = 1:numel(net.layers)
%     if strcmp(net.layers{i}.type, 'conv')
%       conv_layer_indices(end + 1) = i;
%     end
%   end

% % --------------------------------------------------------------------
% function [pre_layer, post_layer] = createBottleneckLayersFromSingleConvLayer(opts, layer_object, bottleneck_size)
% % --------------------------------------------------------------------
%   layer_number = 0; % not important
%   conv_layer_sizes = size(layer_object.weights{1});
%   filter_size = conv_layer_sizes(1); % conv_layer_sizes(2);
%   input_size = conv_layer_sizes(3);
%   output_size = conv_layer_sizes(4);
%   pad = layer_object.pad;
%   pre_layer = convLayer(opts.dataset, opts.network_arch, layer_number, filter_size, input_size, bottleneck_size, 5/100, pad, 'gaussian', 'gen');
%   post_layer = convLayer(opts.dataset, opts.network_arch, layer_number, filter_size, bottleneck_size, output_size, 5/100, pad, 'gaussian', 'gen');
