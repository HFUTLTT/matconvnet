% -------------------------------------------------------------------------
function runTempTests()
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
% % POSSIBILITY OF SUCH DAMAGE.


  % -------------------------------------------------------------------------
  %                                                              opts.general
  % -------------------------------------------------------------------------
  opts.general.dataset = 'cifar';

  % -------------------------------------------------------------------------
  %                                                                opts.train
  % -------------------------------------------------------------------------
  opts.train.gpus = 2;


  % -------------------------------------------------------------------------
  %                                                                opts.paths
  % -------------------------------------------------------------------------
  opts.paths.time_string = sprintf('%s',datetime('now', 'Format', 'd-MMM-y-HH-mm-ss'));
  opts.paths.experiment_parent_dir = getValueFromFieldOrDefault( ...
    {}, ... % no input_opts here! :)
    'experiment_parent_dir', ...
    fullfile(vl_rootnn, 'experiment_results'));
  opts.paths.experiment_dir = fullfile(opts.paths.experiment_parent_dir, sprintf( ...
    'temp-test-%s-GPU-%d', ...
    opts.paths.time_string, ...
    opts.train.gpus));
  if ~exist(opts.paths.experiment_dir)
    mkdir(opts.paths.experiment_dir);
  end
  opts.paths.options_file_path = fullfile(opts.paths.experiment_dir, 'options.txt');
  % opts.paths.results_file_path = fullfile(opts.paths.experiment_dir, 'results.txt');

  % -------------------------------------------------------------------------
  %                                                    save experiment setup!
  % -------------------------------------------------------------------------
  saveStruct2File(opts, opts.paths.options_file_path, 0);


  % dataset_name = sprintf('%s-multi-class-subsampled', opts.general.dataset);
  % balance_name = 'balanced-38';
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'no-projection',                opts.train.gpus);

  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV1P0SF', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV1P1SF', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P0SF', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P1SF', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P3SF', opts.train.gpus);

  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV1P0ST', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV1P1ST', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P0ST', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P1ST', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P3ST', opts.train.gpus);


  % -------------------------------------------------------------------------s


  dataset_name = sprintf('%s', opts.general.dataset);
  balance_name = 'whatever';
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'no-projection',                opts.train.gpus);

  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV1P0SF', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV1P1SF', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P0SF', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P1SF', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P3SF', opts.train.gpus);

  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV1P0ST', opts.train.gpus);
  runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV1P1ST', opts.train.gpus);
  % runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P0ST', opts.train.gpus);
  runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P1ST', opts.train.gpus);
  runLarpTests(opts.paths.experiment_dir, dataset_name, balance_name, 'projected-through-larpV3P3ST', opts.train.gpus);




