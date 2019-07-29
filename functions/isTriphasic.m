function result = isTriphasic(arg1,arg2)
  % find the burst-order
  % accepts either a matrix or cell of calcium peaks
  % or voltage and calcium traces

  % best to run this function in a try-catch block:
  % try
  %   result = isTriphasic(inputs);
  % catch
  %   result = false;
  % end


  if nargin < 2
    assert(iscell(arg1) | ismatrix(arg1),'for one arguments, arguments must be a cell or a matrix of calcium peaks')
    % make sure that the 'big' dimension is the first one
    if size(arg1,1) < size(arg1,2)
      arg1 = arg1';
    end
    usage = 'calcium peaks';
  else
    assert(any(size(arg1) == size(arg2)),'for two arguments, arguments must be the same size')
    % make sure that the 'big' dimension is the first one
    if size(arg1,1) < size(arg1,2)
      arg1 = arg1';
      arg2 = arg2';
    end
    usage = 'voltage and calcium';
  end

  % outputs
  result = true;

  switch usage

  case 'calcium peaks'
    % if the input is a matrix, turn it into a 1-D cell array
    if ~iscell(arg1)
      nCells = size(arg1,2);
      calcium_peaks = cell(nCells,1);
      for ii = 1:nCells
        calcium_peaks{ii} = arg1(:,ii);
      end
    else
      nCells = size(arg1(:));
      calcium_peaks = arg1;
    end

    % make sure there are at least two calcium peaks in the pacemaker cell
    assert(length(calcium_peaks{1}) > 1,'not enough calcium peaks in pacemaker cell')

    for ii = 1:(length(calcium_peaks{1})-1)
      % this is over the # of bursts - 1 so that followers will have a chance to burst as well
      for qq = 2:nCells-1
        try
          if calcium_peaks{qq}(ii) <= calcium_peaks{qq+1}(ii)
            % do nothing
          else
            % if the cells are not in order 1,2,3... then return with 'false'
            result = false;
            return
          end
        catch
          % if there are fewer calcium peaks in the follower cells than the
          % number in the pacemaker minus one, return an error
          error('not enough calcium peaks in follower cell(s)')
        end
      end
    end

  case 'voltage and calcium'
    nCells = size(arg1,2);
    new_arg1 = cell(nCells,1);
    for ii = 1:nCells
      [~,~,new_arg1{ii}] = psychopomp.findBurstMetrics(arg1(:,ii),arg2(:,ii));
    end
    result = isTriphasic(new_arg1);
  otherwise
    error('I have no idea what happened')
  end
