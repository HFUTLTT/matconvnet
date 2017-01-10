function output_opts = cnnAmirInitWithBottlenecks(input_opts)
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

  % -------------------------------------------------------------------------
  %                                                              Parse inputs
  % -------------------------------------------------------------------------

  opts.dataset = input_opts.general.dataset;
  opts.network_arch = input_opts.general.network_arch;
  opts.weight_init_source = input_opts.net.weight_init_source;
  opts.weight_init_sequence = input_opts.net.weight_init_sequence;
  opts.bottleneck_structure = input_opts.net.bottleneck_structure;

  % -------------------------------------------------------------------------
  %                                                         Set learning rate
  % -------------------------------------------------------------------------

  tic;
  s = rng;
  rng(0);
  net.layers = {};
  % Meta parameters
  switch opts.network_arch
    case 'lenet'
      switch opts.dataset
        case 'cifar'
          output_opts.train.learning_rate = [0.05*ones(1,15) 0.005*ones(1,10) 0.0005*ones(1,25)];
        case 'coil-100'
          output_opts.train.learning_rate = [0.05*ones(1,15) 0.005*ones(1,10) 0.0005*ones(1,25)];
        case 'mnist'
          output_opts.train.learning_rate = [0.05*ones(1,15) 0.005*ones(1,10) 0.0005*ones(1,25)];
        case 'stl-10'
          output_opts.train.learning_rate = [0.5*ones(1,20) 0.05*ones(1,15)  0.1:-0.01:0.06 0.05*ones(1,10)];
        case 'svhn'
          output_opts.train.learning_rate = [0.05*ones(1,30) 0.005*ones(1,10) 0.0005*ones(1,10)];
        case 'cifar-two-class-deer-horse'
          output_opts.train.learning_rate = [0.05*ones(1,15) 0.005*ones(1,10) 0.0005*ones(1,25)];
        case 'cifar-two-class-deer-truck'
          output_opts.train.learning_rate = [0.05*ones(1,15) 0.005*ones(1,10) 0.0005*ones(1,25)];
        case 'mnist-two-class-9-4'
          output_opts.train.learning_rate = [0.05*ones(1,15) 0.005*ones(1,10) 0.0005*ones(1,25)];
        case 'svhn-two-class-9-4'
          output_opts.train.learning_rate = [0.05*ones(1,30) 0.005*ones(1,10) 0.0005*ones(1,10)];
        case 'prostate-v2-20-patients'
          output_opts.train.learning_rate = [0.05*ones(1,10) 0.005*ones(1,20) 0.001*ones(1,20)];
      end
    case 'alexnet'
      switch opts.dataset
        case 'cifar'
          output_opts.train.learning_rate = [0.01*ones(1,5) 0.005*ones(1,25) 0.001*ones(1,10) 0.0005*ones(1,5) 0.0001*ones(1,5)]; % amir-LR
        case 'stl-10'
          % still testing ...
          output_opts.train.learning_rate = [0.01*ones(1,5) 0.005*ones(1,25) 0.001*ones(1,10) 0.0005*ones(1,5) 0.0001*ones(1,5)]; % amir-LR
      end
  end

  output_opts.train.num_epochs = numel(output_opts.train.learning_rate);

  fh = networkInitializationUtils;
  switch opts.network_arch
    case 'lenet'
      % -----------------------------------------------------------------------
      %                                                                   LENET
      % -----------------------------------------------------------------------
      % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --  conv block 01
      layer_number = 1;
      net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 5, 3, 32, 1/100, 2, char(opts.weight_init_sequence{1}), opts.weight_init_source);
      net.layers{end+1} = fh.poolingLayerLeNetMax(layer_number);
      net.layers{end+1} = fh.reluLayer(layer_number);

      % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --  conv block 02
      layer_number = layer_number + 3;
      if numel(opts.bottleneck_structure) >= 1
        bottleneck_width = opts.bottleneck_structure(1);
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 5, 32, bottleneck_width, 5/100, 2, char(opts.weight_init_sequence{2}), opts.weight_init_source);
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 5, bottleneck_width, 32, 5/100, 2, char(opts.weight_init_sequence{2}), opts.weight_init_source);
      else
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 5, 32, 32, 5/100, 2, char(opts.weight_init_sequence{2}), opts.weight_init_source);
      end
      net.layers{end+1} = fh.reluLayer(layer_number);
      net.layers{end+1} = fh.poolingLayerLeNetAvg(layer_number);

      % -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --  conv block 03
      layer_number = layer_number + 3;
      if numel(opts.bottleneck_structure) >= 2
        bottleneck_width = opts.bottleneck_structure(2);
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 5, 32, bottleneck_width, 5/100, 2, char(opts.weight_init_sequence{3}), opts.weight_init_source);
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 5, bottleneck_width, 64, 5/100, 2, char(opts.weight_init_sequence{3}), opts.weight_init_source);
      else
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 5, 32, 64, 5/100, 2, char(opts.weight_init_sequence{3}), opts.weight_init_source);
      end
      net.layers{end+1} = fh.reluLayer(layer_number);
      net.layers{end+1} = fh.poolingLayerLeNetAvg(layer_number);

      % FULLY CONNECTED
      layer_number = layer_number + 3;
      net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 4, 64, 64, 5/100, 0, 'compRand', 'gen');
      net.layers{end+1} = fh.reluLayer(layer_number);

      layer_number = layer_number + 2;
      if isTwoClassImdb(opts.dataset)
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 1, 64, 2, 5/100, 0, 'compRand', 'gen');
      elseif strcmp(opts.dataset, 'coil-100')
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 1, 64, 100, 5/100, 0, 'compRand', 'gen');
      else
        net.layers{end+1} = fh.convLayer(opts.dataset, opts.network_arch, layer_number, 1, 64, 10, 5/100, 0, 'compRand', 'gen');
      end

      % LOSS LAYER
      net.layers{end+1} = fh.softmaxlossLayer();
  end

  % -------------------------------------------------------------------------
  %    VERY IMPORTANT: reset this afterwards so other modules are true random
  % -------------------------------------------------------------------------
  rng(s);
  output_opts.net.net = net;








