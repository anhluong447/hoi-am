"""Validate authored dialogue motion numbers and component coverage."""
import math


def validate(layout):
    motion = layout['motion']
    def finite(value):
        assert type(value) in (int, float) and math.isfinite(value)
        return value
    def positive(value):
        assert finite(value) > 0
    def offset(value):
        assert len(value) == 2
        for item in value: finite(item)
    opening = {'wave', 'paper', 'date', 'flowers', 'notebook', 'speaker', 'body'}
    assert set(motion['opening']) == opening
    assert set(motion['closing']) == opening | {'choices', 'proceed'}
    for specs in [motion['opening'], motion['closing']]:
        for spec in specs.values():
            assert finite(spec['delay']) >= 0
            positive(spec['duration'])
            if 'offset' in spec: offset(spec['offset'])
            if 'rotation' in spec: finite(spec['rotation'])
    for value in motion['pivots'].values(): offset(value)
    for field in ['text_delay', 'line_out_duration', 'line_in_duration']: positive(motion[field])
    ink = motion['typewriter']
    for field in ['characters_per_second', 'soft_duration', 'blur_padding']: positive(ink[field])
    assert 0 <= finite(ink['blur_radius']) <= ink['blur_padding']
    for pause in ink['punctuation_pauses'].values(): assert finite(pause) >= 0
    rows = motion['choices']
    for field in ['duration', 'stagger', 'focus_duration']: positive(rows[field])
    assert finite(rows['focus_scale']) >= 1
    assert finite(rows['chevron_offset']) >= 0
    offset(rows['offset'])
    for field, value in motion['idle'].items():
        assert finite(value) >= 0
        if field.endswith('_period') or field == 'shimmer_width': positive(value)
    assert 0 <= motion['idle']['proceed_min_alpha'] <= 1
    region = motion['advance_region']
    assert len(region) == 4 and all(finite(value) >= 0 for value in region)
    assert region[2] > 0 and region[3] > 0
