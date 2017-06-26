% -------------------------------------------------------------------------
function tempScriptMeasureClassificationPerformance(dataset, posneg_balance, save_results)
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

  % -------------------------------------------------------------------------
  %                                                                     Setup
  % -------------------------------------------------------------------------
  classification_method = 'cnn';
  repeat_count = 30;
  all_experiments_multi_run = {};

  for i = 1 : 22
    all_experiments_multi_run{i}.test_performance = [];
  end

  for kk = 1:repeat_count
    all_experiments_single_run = runAllExperimentsOnce(dataset, posneg_balance, classification_method);
    for i = 1 : numel(all_experiments_single_run)
      all_experiments_multi_run{i}.test_performance(end + 1) = ...
        all_experiments_single_run{i}.performance_summary.testing.test.accuracy;
    end
  end

  plotBeef(all_experiments_multi_run, dataset, save_results);

% -------------------------------------------------------------------------
function all_experiments_single_run = runAllExperimentsOnce(dataset, posneg_balance, classification_method)
% -------------------------------------------------------------------------
  opts.general.dataset = dataset;
  opts.general.posneg_balance = posneg_balance;
  [~, experiments] = setupExperimentsUsingProjectedImbds(dataset, posneg_balance, 0);

  % -------------------------------------------------------------------------
  %                                                                opts.paths
  % -------------------------------------------------------------------------
  opts.paths.time_string = sprintf('%s',datetime('now', 'Format', 'd-MMM-y-HH-mm-ss'));
  opts.paths.experiment_parent_dir = getValueFromFieldOrDefault( ...
    {}, ... % no input_opts here! :)
    'experiment_parent_dir', ...
    fullfile(vl_rootnn, 'experiment_results'));
  opts.paths.experiment_dir = fullfile(opts.paths.experiment_parent_dir, sprintf( ...
    'test-angle-separation-rp-tests-%s-%s-%s-GPU-%d', ...
    opts.paths.time_string, ...
    opts.general.dataset, ...
    opts.general.posneg_balance));
  if ~exist(opts.paths.experiment_dir)
    mkdir(opts.paths.experiment_dir);
  end
  opts.paths.options_file_path = fullfile(opts.paths.experiment_dir, 'options.txt');


  % -------------------------------------------------------------------------
  %                                       opts.single_training_method_options
  % -------------------------------------------------------------------------
  opts.single_training_method_options.experiment_parent_dir = opts.paths.experiment_dir;
  opts.single_training_method_options.dataset = dataset;
  opts.single_training_method_options.return_performance_summary = true;
  switch classification_method
    case 'knn'
      classificationMethodFunctonHandle = @testKnn;
      % no additional options
    case 'cnn'
      classificationMethodFunctonHandle = @testCnn;
      opts.single_training_method_options.network_arch = 'convV0P0RL0+fcV1-RF32CH3';
      opts.single_training_method_options.backprop_depth = 4;
      opts.single_training_method_options.gpus = ifNotMacSetGpu(1);
      opts.single_training_method_options.debug_flag = false;
      opts.single_training_method_options.learning_rate = [0.1*ones(1,15) 0.03*ones(1,15) 0.01*ones(1,15)];
      % opts.single_training_method_options.learning_rate = [0.1*ones(1,3)];
      opts.single_training_method_options.weight_decay = 0.0001;
      opts.single_training_method_options.batch_size = 50;
  end

  % -------------------------------------------------------------------------
  %                                                    save experiment setup!
  % -------------------------------------------------------------------------
  saveStruct2File(opts, opts.paths.options_file_path, 0);

  for i = 1 : numel(experiments)
    opts.single_training_method_options.imdb = experiments{i}.imdb;
    [~, experiments{i}.performance_summary] = classificationMethodFunctonHandle(opts.single_training_method_options);
    % all_experiments_repeated{i}.performance_summary.testing.test.accuracy = []
  end

  for i = 1 : numel(experiments)
    afprintf(sprintf( ...
      '[INFO] 1-KNN Results for `%s`: \t\t train acc = %.4f, test acc = %.4f \n\n', ...
      experiments{i}.title, ...
      experiments{i}.performance_summary.testing.train.accuracy, ...
      experiments{i}.performance_summary.testing.test.accuracy));
  end

  all_experiments_single_run = experiments;


% -------------------------------------------------------------------------
function plotBeef(all_experiments_multi_run, dataset, save_results)
% -------------------------------------------------------------------------
  y_all = [];
  y_wo_relu = [];
  y_w_relu = [];
  std_errors_value_all = [];
  std_errors_value_wo_relu = [];
  std_errors_value_w_relu = [];
  exp_number = 1;
  for j = 1:2
    for i = 1:11
      y_all(i,j) = mean(all_experiments_multi_run{exp_number}.test_performance);
      std_errors_value_all(i,j) = std(all_experiments_multi_run{exp_number}.test_performance);
      exp_number = exp_number + 1;
    end
  end

  y_wo_relu = [y_all(1,:); y_all(2:6,:)];
  y_w_relu = [y_all(1,:); y_all(7:11,:)];

  std_errors_value_wo_relu = reshape([std_errors_value_all(1,:); std_errors_value_all(2:6,:)]', 1, []);
  std_errors_value_w_relu = reshape([std_errors_value_all(1,:); std_errors_value_all(7:11,:)]', 1, []);


  std_errors_x_location = [ ...
    0.86, 1.14, ...
    1.86, 2.14, ...
    2.86, 3.14, ...
    3.86, 4.14, ...
    4.86, 5.14, ...
    5.86, 6.14];
  std_errors_y_location = reshape(y_all', 1, []);
  std_errors_y_location_wo_relu = cat(2, std_errors_y_location(1:2), std_errors_y_location(3:12));
  std_errors_y_location_w_relu = cat(2, std_errors_y_location(1:2), std_errors_y_location(13:22));

  h = figure;

  subplot(1,2,1);
  subplotBeef(y_wo_relu, std_errors_x_location, std_errors_y_location_wo_relu, std_errors_value_wo_relu, 'w/o ReLU');

  subplot(1,2,2);
  subplotBeef(y_w_relu, std_errors_x_location, std_errors_y_location_w_relu, std_errors_value_w_relu, 'w ReLU');

  tmp_string = sprintf('1-KNN - %s', dataset);
  suptitle(tmp_string);
  if save_results
    % saveas(h, fullfile(getDevPath(), 'temp_images', sprintf('%s.png', tmp_string)));
    print(fullfile(getDevPath(), 'temp_images', tmp_string), '-dpdf', '-fillpage')
  end

% -------------------------------------------------------------------------
function subplotBeef(y, std_errors_x_location, std_errors_y_location, std_errors_value, title_string)
% -------------------------------------------------------------------------
  hold on;
  bar(y);
  ylim([-0.1, 1.1]);
  errorbar(std_errors_x_location, std_errors_y_location, std_errors_value);
  legend({'original imdb', 'angle separated imdb'}, 'Location','southeast');
  title(title_string);

  % Set the X-Tick locations so that every other month is labeled.
  Xt = 1:1:6;
  Xl = [0.5 6.5];
  set(gca, 'XTick', Xt, 'XLim', Xl);

  % Add the months as tick labels.
  labels = ['Default';
            '-------';
            'RP =  1';
            '-------';;
            'RP =  2';
            '-------';;
            'RP =  3';
            '-------';;
            'RP =  4';
            '-------';;
            'RP =  5';
            '-------';];
  ax = axis;     % Current axis limits
  axis(axis);    % Set the axis limit modes (e.g. XLimMode) to manual
  Yl = ax(3:4);  % Y-axis limits

  % Place the text labels
  t = text(Xt, Yl(1) * ones(1, length(Xt)), labels(1:2:12,:));
  set(t, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Rotation', 45);

  % Remove the default labels
  set(gca,'XTickLabel','');
  hold off












