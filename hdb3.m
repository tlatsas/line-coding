function hdb3( bitstream )
    %HDB3 High Density Bipolar 3-zeros
    %   sample data:
    %       d = [ 1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 1 0 ]
    %   usage:
    %       hdb3(d)
    %   author:
    %       Anastasios Latsas

    % pulse height
    pulse = 5;

    % assume that current pulse level is a "low" pulse; this is
    % the pulse level for the bit before given bitstream
    current_level = -pulse;

    % assume odd number of ones before given bistream
    ones = 1;

    % define violation patterns
    negative_odd = [ '0' '0' '0' '-' ];
    positive_odd = [ '0' '0' '0' '+' ];
    negative_even = [ '+' '0' '0' '+' ];
    positive_even = [ '-' '0' '0' '-' ];

    bit = 1;
    while bit <= length(bitstream)
        % set bit time
        bt=bit-1:0.001:bit;

        if bitstream(bit) == 0
            % if more than 4 zeros found introduce violation
            if consecutive_zeros(bitstream, bit) >= 4
                % select violation pattern
                pattern = get_pattern(current_level, ones);

                % operate on each bit of violation pattern array
                for v_bit = 1:4
                    % calculate bit time for violation pattern
                    % we continue from previous index
                    % where 'bit' and 'v_bit' variables are used together
                    % we need to substract 1 because pattern[1] is actually
                    % bitstream[bit]
                    v_bt = (v_bit+bit-2):0.001:(v_bit+bit-1);
                    switch pattern(v_bit)
                        case '0'
                            y = zeros(size(v_bt));
                        case '+'
                            y = (v_bt<v_bit+bit-1) * pulse;
                            current_level = pulse;
                        case '-'
                            y = (v_bt<v_bit+bit-1) * -pulse;
                            current_level = -pulse;
                    end

                    % inspect next bit in violation pattern
                    try
                        if pattern(v_bit + 1) == '+'
                            y(end) = pulse;
                        elseif pattern(v_bit + 1) == '-'
                            y(end) = -pulse;
                        end
                    catch e
                            % violation pattern end, try original data
                            try
                                if bitstream(bit+4) == 1
                                    y(end) = -current_level;
                                else
                                    % if original data continues with zeros
                                    % examine if a next violation will follow
                                    if consecutive_zeros(bitstream, bit + 4) >= 4
                                        % what pattern will be used next
                                        next_pattern = get_pattern(current_level, 0);
                                        if next_pattern(1) == '+'
                                            y(end) = pulse;
                                        elseif next_pattern(1) == '-'
                                            y(end) = -pulse;
                                        end
                                    end
                                end
                            catch e
                                % bitstream end, assume next bit is 1
                                y(end) = -current_level;
                            end
                    end
                    draw_pulse(v_bt, y, pulse, v_bit+bit-1, pattern(v_bit))
                end
                % skip zeros in original data
                bit = bit + 4;
                % reset ones counter
                ones = 0;
                continue
            else
                y = zeros(size(bt));
            end
        else
            % increase number of ones since last violation
            ones = ones + 1;
            % change current levels
            current_level = -current_level;
            % binary 1
            y = (bt<bit) * current_level;
        end

        % assign last pulse point by inspecting the following bit
        try
            if bitstream(bit+1) == 1
                y(end) = -current_level;
            else
                % next bit in bitstream is 0, guess if a
                % violation will be introduced in the future
                if consecutive_zeros(bitstream, bit + 1) >= 4
                    % what pattern will be used next
                    next_pattern = get_pattern(current_level, ones);
                    if next_pattern(1) == '+'
                        y(end) = pulse;
                    elseif next_pattern(1) == '-'
                        y(end) = -pulse;
                    end
                end
            end
        catch e
            % bitstream end; assume next bit is 1
            y(end) = -current_level;
        end

        % draw pulse
        draw_pulse(bt, y, pulse, bit, num2str(bitstream(bit)))
        % move to the next bit
        bit = bit + 1;
    end
    % draw grid
    grid on;
    axis([0 length(bitstream) -pulse*2 pulse*2]);
    set(gca,'YTick', [-pulse 0 pulse])
    set(gca,'XTick', 1:length(bitstream))
    set(gca,'XTickLabel', '')
    title('High Density Bipolar 3-zeros')

    % //-------------------------------------------------------------------
    % // sub-functions
    % //-------------------------------------------------------------------

    function draw_pulse(x, y, height, b, bit_label)
        % draw a single pulse and the bit it represents
        % parameters:
        %   x:         bit time (axis x)
        %   y:         pulse levels (axis y)
        %   height:    pulse height
        %   b:         bit index in bitstream array
        %   bit_label: the digit this pulse represents
        plot(x, y, 'LineWidth', 2);
        text(b-0.5, height+2, bit_label, 'FontWeight', 'bold')
        hold on;
    end

    function num = consecutive_zeros(bitstream, pos)
        % count consecutive zeros in an array from given position
        % parameters:
        %   bitstream: array of bits to be searched
        %   pos:       position in the array to start counting
        num = 0;
        for b = pos:length(bitstream)
            if bitstream(b) == 0
                num = num + 1;
            else
                return
            end
        end
    end

    function pattern = get_pattern(current_level, ones)
        % select violation pattern based on pulse level
        % and binary 1s transmitted
        % parameters:
        %   current_level: pulse level
        %   ones:          number of transmitted ones since last violation

        % TODO:
        %   pass pattern arrays as parameters to make it compatible
        %   with octave.
        if current_level > 0
            if mod(ones, 2) == 0
                pattern = positive_even;
            else
                pattern = positive_odd;
            end
        else
            if mod(ones, 2) == 0
                pattern = negative_even;
            else
                pattern = negative_odd;
            end
        end
    end
end
