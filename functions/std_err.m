function output = std_err(value, target)
  % computes the standard error of the mean wih a target value
  if target == 0
    output = (value)^2;
    return
  end

  output = (value - target)^2 / target^2;

  if isnan(output)
    output = 0;
  end

end
