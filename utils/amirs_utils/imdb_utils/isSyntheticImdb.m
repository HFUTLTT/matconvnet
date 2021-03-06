% -------------------------------------------------------------------------
function output = isSyntheticImdb(dataset)
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

  output = false;
  % if ...
    % strcmp(dataset, 'gaussian-5D-160-train-40-test') || ...
    % strcmp(dataset, 'gaussian-10D-160-train-40-test') || ...
    % strcmp(dataset, 'gaussian-25D-160-train-40-test') || ...
    % strcmp(dataset, 'gaussian-50D-160-train-40-test') || ...
    % ...
    % strcmp(dataset, 'gaussian-5D-400-train-100-test') || ...
    % strcmp(dataset, 'gaussian-10D-400-train-100-test') || ...
    % strcmp(dataset, 'gaussian-25D-400-train-100-test') || ...
    % strcmp(dataset, 'gaussian-50D-400-train-100-test') || ...
    % ...
    % strcmp(dataset, 'gaussian-50D-800-train-200-test')

  %   output = true;
  % end

  if strfind(dataset, 'saved-multi-class-gaussian-')
    output = true;
  end

  if strfind(dataset, 'saved-multi-class-circles-')
    output = true;
  end

  if strfind(dataset, 'saved-multi-class-spirals-')
    output = true;
  end

  if strfind(dataset, 'xor-')
    output = true;
  end

  if strfind(dataset, 'rings-')
    output = true;
  end

  if strfind(dataset, 'spirals-')
    output = true;
  end

  if strfind(dataset, 'shapes')
    output = true;
  end









