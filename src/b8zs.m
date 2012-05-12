function b8zs( bitstream )
    % B8ZS Bipolar with 8-Zeros Substitution
    %   sample data:
    %       d = [ 1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 1 0 ]
    %   usage:
    %       b8zs(d)
    %   author:
    %       Anastasios Latsas

    % pulse height
    pulse = 5;

    % assume that current pulse level is a "low" pulse; this is
    % the pulse level for the bit before given bitstream
    current_level = -pulse;

    % define violation patterns
    % positive_violation: used when bit before violation has positive pulse
    % negative_violation: used when bit before violation has negative pulse
    positive_violation = [ '0' '0' '0' '+' '-' '0' '-' '+' ];
    negative_violation = [ '0' '0' '0' '-' '+' '0' '+' '-' ];

    bit = 1;
    while bit <= length(bitstream)
        % set bit time
        bt=bit-1:0.001:bit;

        if bitstream(bit) == 0
            % count zeros, if more than 8 found introduce violation
            if consecutive_zeros(bitstream, bit) >= 8
                % select violation pattern according to previous pulse
                if current_level > 0
                    pattern = positive_violation;
                else
                    pattern = negative_violation;
                end

                % operate on each bit of violation pattern array
                for v_bit = 1:8
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
                                if bitstream(bit+8) == 1
                                    y(end) = -current_level;
                                end
                            catch e
                                % bitstream end, assume next bit is 1
                                y(end) = -current_level;
                            end
                    end
                    draw_pulse(v_bt, y, pulse, v_bit+bit-1, pattern(v_bit))
                end
                % skip zeros in original data
                bit = bit + 8;
                continue
            else
                % less that 8 zeros found, draw 0
                y = zeros(size(bt));
            end
        else
            % each binary 1 has the opposite pulse level from the previous
            current_level = -current_level;
            y = (bt<bit) * current_level;
        end

        % assign last pulse point by inspecting the following bit
        try
            % we care only about binary 1, zeros will always
            % start at zero level (including violation patterns)
            if bitstream(bit+1) == 1
                y(end) = -current_level;
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
    title('Bipolar with 8-Zeros Substitution')

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
end
