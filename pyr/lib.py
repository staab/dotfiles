import re, itertools, uuid
from copy import copy
from collections import OrderedDict
from inspect import signature


def curry_n(n, fn, carryover_args=(), carryover_kwargs=()):
    def _curried(*args, **kwargs):
        cur_n = len(args) + len(kwargs)

        # Rebuild the carryover dict to avoid mutation
        combined_args = carryover_args + args
        combined_kwargs = {}
        combined_kwargs.update(carryover_kwargs)
        combined_kwargs.update(kwargs)

        if cur_n >= n:
            return fn(*combined_args, **combined_kwargs)
        else:
            return curry_n(n - cur_n, fn, combined_args, combined_kwargs)

    _curried._arity = n

    return _curried


def curry_n_dec(n):
    def _curry_fn(fn):
        fn.c = curry_n(n, fn)

        return fn

    return _curry_fn


def partial(fn, *args, **kwargs):
    def _partialed(*other_args, **other_kwargs):
        return fn(*(args + other_args), **merge(kwargs, other_kwargs))

    return _partialed


def arity(fn):
    return getattr(fn, '_arity', len(signature(fn).parameters))


@curry_n_dec(2)
def n_ary(arity, fn):
    return lambda *args: fn(*args[:arity])


def self_arity(fn):
    return n_ary(arity(fn), fn)


def unary(fn):
    return n_ary(1, fn)


def binary(fn):
    return n_ary(2, fn)


@curry_n_dec(2)
def mapl(fn, data):
    return (
        {key: fn(value) for key, value in data.items()}
        if type(data) == dict else
        [fn(item) for item in data]
    )


@curry_n_dec(2)
def filterl(fn, data):
    return (
        {key: value for key, value in data.items() if fn(value)}
        if type(data) == dict else
        [item for item in data if fn(item)]
    )


@curry_n_dec(3)
def reducel(fn, value, data):
    for item in data:
        value = fn(value, item)

    return value


@curry_n_dec(2)
def reject(fn, data):
    return (
        {key: value for key, value in data.items() if not fn(value)}
        if type(data) == dict else
        [item for item in data if not fn(item)]
    )


@curry_n_dec(3)
def when(test, fn, x):
    return fn(x) if test(x) else x


@curry_n_dec(2)
def find(fn, data):
    for item in data:
        if fn(item):
            return item

@curry_n_dec(2)
def find_index(fn, xs):
    for idx, x in enumerate(xs):
        if fn(x):
            return idx


def uniq(data):
    return list(set(data))


@curry_n_dec(2)
def uniq_by(fn, data):
    result = OrderedDict()
    for item in data:
        key = fn(item)
        result.setdefault(key, item)

    return list(result.values())


@curry_n_dec(2)
def index_by(get_key, coll):
    return {get_key(item): item for item in coll}


@curry_n_dec(2)
def index_of(item, coll):
    for idx, value in enumerate(coll):
        if value == item:
            return idx

    return -1


@curry_n_dec(2)
def map_obj_indexed(fn, obj):
    fn = self_arity(fn)

    return {key: fn(value, key, obj) for key, value in obj.items()}


@curry_n_dec(2)
def equals(value1, value2):
    return value1 == value2


@curry_n_dec(2)
def identical(value1, value2):
    return value1 is value2


@curry_n_dec(2)
def lt(a, b):
    return a < b


@curry_n_dec(2)
def lte(a, b):
    return a <= b


@curry_n_dec(2)
def gt(a, b):
    return a > b


@curry_n_dec(2)
def gte(a, b):
    return a >= b


@curry_n_dec(2)
def prop(prop_name, obj):
    try:
        return obj[prop_name]
    except (IndexError, KeyError):
        return None
    except TypeError:
        return getattr(obj, prop_name, None)


@curry_n_dec(2)
def path(_path, obj):
    while _path:
        head, *_path = _path
        obj = prop(head, obj)

    return obj


@curry_n_dec(3)
def prop_eq(prop_name, val, obj):
    return prop(prop_name, obj) == val


@curry_n_dec(3)
def path_eq(_path, val, obj):
    return path(_path, obj) == val


@curry_n_dec(2)
def concat(*l):
    return [item for sublist in l for item in sublist]


def flatten(l):
    if not hasattr(l, '__iter__') or isinstance(l, (dict, str)):
        return [l]

    r = []
    for x in l:
        r.extend(flatten(x))

    return r


@curry_n_dec(2)
def without(sans, target):
    sans = set(sans)

    return [element for element in target if element not in sans]


@curry_n_dec(2)
def contains(x, xs):
    return x in xs


@curry_n_dec(2)
def starts_with(x, xs):
    return xs.startswith(x)


@curry_n_dec(2)
def split(delimiter, value):
    return value.split(delimiter)


@curry_n_dec(2)
def join(delimiter, value):
    return delimiter.join(value)


def merge_all(dicts):
    result = {}
    for d in dicts:
        result.update(d)

    return result


@curry_n_dec(2)
def merge(*dicts):
    result = {}
    for d in dicts:
        result.update(d)

    return result


@curry_n_dec(2)
def zip_obj(keys, values):
    result = {}
    for idx, key in enumerate(keys):
        result[key] = values[idx]

    return result


@curry_n_dec(2)
def pick(keys, data):
    return {key: data[key] for key in keys if key in data}


@curry_n_dec(2)
def omit(keys, data):
    result = {}
    for key, value in data.items():
        if key in keys:
            continue

        result[key] = value

    return result


@curry_n_dec(3)
def assoc(key, value, data):
    result = copy(data)

    if type(data) == dict:
        result.update({key: value})
    else:
        setattr(result, key, value)

    return result


@curry_n_dec(3)
def assoc_path(_path, value, data):
    if not hasattr(data, '__setitem__'):
        data = {}

    head, *tail = _path

    value = assoc_path(tail, value, data.get(head, {})) if tail else value

    result = copy(data)
    result[head] = value

    return result


@curry_n_dec(2)
def pluck(key, coll):
    return mapl(prop.c(key), coll)


@curry_n_dec(2)
def all_fn(fn, coll):
    for x in coll:
        if not fn(x):
            return False

    return True


@curry_n_dec(2)
def any_fn(fn, coll):
    for x in coll:
        if fn(x):
            return True

    return False


@curry_n_dec(2)
def none(fn, coll):
    for x in coll:
        if fn(x):
            return False

    return True


@curry_n_dec(2)
def where(spec, obj):
    for key, fn in spec.items():
        if not fn(prop(key, obj)):
            return False

    return True


@curry_n_dec(2)
def where_eq(spec, obj):
    for key, value in spec.items():
        if value != prop(key, obj):
            return False

    return True


@curry_n_dec(2)
def group_by(fn, coll):
    result = {}
    for item in coll:
        key = fn(item)
        result.setdefault(key, [])
        result[key].append(item)

    return result


@curry_n_dec(2)
def count_by(fn, coll):
    result = {}
    for item in coll:
        key = fn(item)
        result.setdefault(key, 0)
        result[key] += 1

    return result


def pipe(*fns):
    def _piped(value):
        for fn in fns:
            value = fn(value)

        return value

    return _piped


def invoker(arity, method_name):
    @curry_n_dec(arity)
    def invoke(*args):
        obj = args[-1]
        method = getattr(obj, method_name)

        return method(args[:-1])

    return invoke


@curry_n_dec(3)
def replace(find, replace, value):
    return value.replace(find, replace)


def reverse(xs):
    return list(reversed(xs))


def always(val):
    return lambda *args, **kwargs: val


def identity(val):
    return val


def difference(l1, l2):
    return [item for item in l1 if item not in l2]


@curry_n_dec(3)
def flip(fn, arg1, arg2):
    return fn(arg2, arg1)


@curry_n_dec(2)
def nth(idx, xs):
    return xs[idx]


def last(l):
    return l[-1] if l else None


@curry_n_dec(2)
def add(x, y):
    return x + y


@curry_n_dec(2)
def subtract(x, y):
    return x - y


@curry_n_dec(2)
def obj_of(k, v):
    return {k: v}


def values(m):
    return m.values()


UUID_PATTERN = "\
^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$"


def noop(*args, **kwargs):
    pass


def first(xs):
    # Handle sequences that don't support indexing
    for x in xs:
        return x


def uuid_str():
    return str(uuid.uuid4())


def enforce_in(keys, obj, exc=None):
    missing = list(set(keys) - set(obj.keys()))

    if len(missing):
        message = "Missing keys %s in %s" % (missing, list(obj.keys()))
        if exc is None:
            raise ValueError(message)
        raise type(exc)(str(exc) + " " + message)


def modify_exc_message(exc, modify):
    # Mutate the exception to keep the stack trace intact
    if hasattr(exc, 'message'):
        exc.message = modify(exc.message)
    else:
        exc.args = (modify(str(exc.args[0])), *exc.args[1:])

    return exc


def append_exc_message(exc, msg):
    return modify_exc_message(exc, lambda arg: "{} {}".format(arg, msg))


def ensure_list(value):
    return value if type(value) == list else [value]


def concat_all(lists):
    return concat(*lists)


def group_by_key(key, items):
    return group_by(prop.c(key), items)


def diff_collections(old, new):
    diff = {
        'added': [],
        'changed': [],
        # Anything in old that's gone in new
        'removed': [
            old_item for old_item in old
            if not find(prop_eq.c('id', old_item['id']), new)
        ],
    }

    for new_item in new:
        old_item = find(prop_eq.c('id', new_item['id']), old)

        # Anything in new that's gone in old
        if not old_item:
            diff['added'].append(new_item)
        # Anything that changed but is still around
        elif new_item != old_item:
            diff['changed'].append({
                'from': old_item,
                'to': new_item,
            })

    return diff


def diff_dicts(a, b):
    diff = []

    for k in uniq(concat(a.keys(), b.keys())):
        if k not in a and k in b:
            diff.append(f'key "{k}" is new. New value: {b[k]}')
        elif k not in b and k in a:
            diff.append(f'key "{k}" was removed. Old value: {a[k]}')
        elif a[k] != b[k]:
            diff.append(
                f'key "{k}" was changed. Old value: {a[k]}; New value: {b[k]}'
            )

    return diff


def convert_leaves(value, from_type, convert):
    if isinstance(value, list):
        return [convert_leaves(member, from_type, convert) for member in value]
    elif isinstance(value, dict):
        return {
            key: convert_leaves(member, from_type, convert)
            for key, member in value.items()
        }
    elif isinstance(value, from_type):
        return convert(value)
    else:
        return value


def safe_divide(x, y):
    return x / y if y != 0 else 0.0


def is_none(x):
    return x is None


def is_not_none(x):
    return x is not None


def is_digits(x):
    return re.search("^[0-9]+$", x) is not None


def slurp(path, mode="r"):
    with open(path, mode) as f:
        output = f.read()

    return output


def get_subset_of(a, b):
    if isinstance(a, list) and isinstance(b, list):
        return mapl(partial(get_subset_of, first(a)), b)

    def recursible(v):
        return isinstance(v, dict) or (
            isinstance(v, list) and isinstance(first(v), dict))

    return {
        k: v if not recursible(v) else get_subset_of(a[k], v)
        for k, v in b.items()
        if k in a}


@curry_n_dec(2)
def create_map(key, collection):
    return index_by(prop.c(key), collection)


@curry_n_dec(3)
def create_map_of(key, value_key, collection):
    result = {}
    for item in collection:
        result[prop(key, item)] = prop(value_key, item)

    return result


def union_keys(*dicts):
    result = set()
    for d in dicts:
        result = result.union(set(d.keys()))

    return result


@curry_n_dec(2)
def merge_right(*d):
    return merge(*reversed(d))


@curry_n_dec(3)
def merge_in(key, overrides, data):
    return update_in(key, merge_right.c(overrides), data)


@curry_n_dec(3)
def merge_in_right(key, overrides, data):
    return update_in(key, merge.c(overrides), data)


def merge_right_fn(result, d2):
    """
    Merge defaults in but lazily evaluate them in case they're expensive
    """
    for key, get_value in d2.items():
        if key not in result:
            result = merge(result, {key: get_value()})

    return result


def modify(data, rename={}, pick=[], omit=[], defaults={}, overrides={}):
    rename_map = pick(rename.keys(), data)

    if pick:
        data = pick(pick, data)

    if omit:
        data = omit(omit, data)

    renamed = {rename[key]: value for key, value in rename_map.items()}

    return merge(defaults, data, renamed, overrides)


@curry_n_dec(3)
def rename_prop(from_prop, to_prop, data):
    return modify(data, omit=[from_prop], overrides={to_prop: data[from_prop]})


@curry_n_dec(3)
def rename_path(from_path, to_path, data):
    # find the value
    value = path(from_path, data)

    # Remove it from the data structure
    update_path(from_path[:-1], omit.c(from_path[-1]), data)

    # Stick it where it belongs
    return assoc_path(to_path, value, data)


@curry_n_dec(3)
def update_path(path, fn, data):
    value = path(path, data)
    parent = path(path[:-1], data) if len(path) > 1 else data
    args = [value, parent, data][:arity(fn)]

    return assoc_path(path, fn(*args), data)


@curry_n_dec(3)
def update_in(key, fn, data):
    return update_path([key], fn, data)


# https://stackoverflow.com/a/2166841/1467342
def is_namedtuple(value):
    bases = value.__bases__

    if len(bases) != 1 or bases[0] != tuple:
        return False

    fields = getattr(value, '_fields', None)

    if not isinstance(fields, tuple):
        return False

    return all(type(name) == str for name in fields)


def instanceof_namedtuple(value):
    return is_namedtuple(type(value))


def with_id(entity_data, entity_id):
    return merge(entity_data, {'id': entity_id})


def extract(key, data):
    return data[key], omit([key], data)


@curry_n_dec(2)
def modify_keys_recursive(fn, value):
    if isinstance(value, list):
        return mapl(modify_keys_recursive.c(fn), value)

    if isinstance(value, dict):
        return zip_obj(
            mapl(fn, value.keys()),
            mapl(modify_keys_recursive.c(fn), value.values())
        )

    return value

@curry_n_dec(2)
def modify_values_recursive(fn, value):
    if isinstance(value, list):
        return mapl(modify_values_recursive.c(fn), value)

    if isinstance(value, dict):
        return zip_obj(
            value.keys(),
            mapl(modify_values_recursive.c(fn), value.values())
        )

    return fn(value)


def do_pipe(value, fns):
    for fn in fns:
        if callable(fn):
            value = fn(value)
        else:
            fn, *args = fn
            value = fn(*args + [value])

    return value


def get_dupes(l):
    seen = set()
    dupes = set()
    for item in l:
        if item in seen:
            dupes.add(item)
        else:
            seen.add(item)

    return dupes


@curry_n_dec(2)
def clog(label, v):
    print(label, v)
    return v


@curry_n_dec(2)
def fill_dict(keys, value):
    return {key: value for key in keys}


@curry_n_dec(2)
def get_dict_key(value, d):
    for k, v in d:
        if v == value:
            return k


def ichunk(n, iterable):
    iterator = iter(iterable)

    while True:
        chunk = list(itertools.islice(iterator, n))

        if not chunk:
            return

        yield chunk


def do_all(iterable):
    for x in iterable:
        pass


def parse_bool(value):
    if type(value) == bool:
        return value

    value = to_snake(str(value))

    if value in ['1', 'yes', 'true', 'y', 't']:
        return True
    elif value in ['0', 'no', 'false', 'n', 'f']:
        return False


def multi_dict_to_dict(md):
    # arrays are a little silly in query strings. they can either
    # by the same key repeated (foo=bar&foo=baz) or use the bracket
    # syntax (foo[]=bar&foo[]=baz). We're opting for bracket syntax
    # for simplicity for now.
    # params come in as a list of values mapped to a key, so we want to
    # singular-ize them if we're not expecting a list, or remove the brackets
    # if we are
    def transform_query_arg(kv):
        key, values = kv

        return (
            {key[:-2]: values}
            if key.endswith("[]") else
            {key: first(ensure_list(values))}
        )

    return merge_all(map(transform_query_arg, dict(md).items()))


def delimit(values, conjunction='and'):
    if len(values) == 0:
        return ''
    elif len(values) == 1:
        return values[0]
    elif len(values) == 2:
        return "{} {} {}".format(values[0], conjunction, values[1])
    elif len(values) > 8:
        return "{}, {} {} others".format(
            ", ".join(values[:6]),
            conjunction,
            len(values) - 6
        )

    return "{}, {} {}".format(", ".join(values[:-1]), conjunction, values[-1])


def pluralize(n, label, pluralLabel=None):
    return label if n == 1 else (pluralLabel or '{}s'.format(label))


class Obj(object):
    def __init__(self, **data):
        self.data = data

    def __getattr__(self, name):
        if name == 'data':
            return super(Obj, self).__getattr__(name)

        try:
            return self.data[name]
        except KeyError:
            raise AttributeError(name)


def thread_last(value, ops):
    for key, args in ops.items():
        if type(args) != tuple:
            args = (args,)

        if key == 'pipe':
            fn = pipe(*args)
            value = fn(value)
            continue

        try:
            fn = getattr(R, key)
        except AttributeError:
            fn = locals()[key]

        value = fn(*list(args) + [value])

    return value


@curry_n_dec(3)
def prop_ne(prop_name, val, obj):
    return prop(prop_name, obj) != val


def ensure_bytes(s):
    if isinstance(s, str):
        return s.encode('utf-8')

    return s


def listify(xs):
    return [x for x in flatten(xs) if x is not None]


def always_raise(exc):
    def raiser(*args, **kwargs):
        raise exc

    return raiser


def if_none(a, b):
    return b if a is None else a


def eager(fn):
    def wrapper(*args, **kwargs):
        return list(fn(*args, **kwargs))

    return wrapper


def ellipsize(s, l, suffix='...'):
    if len(s) < l * 1.1:
        return s

    while len(s) > l and ' ' in s:
        s, *_ = s.rpartition(' ')

    return s + suffix


def to_snake(value):
    return re.sub(
        '([a-z0-9])([A-Z])',
        r'\1_\2',
        re.sub(
            '(^_)_*([A-Z][a-z]+)',
            r'\1_\2',
            re.sub(r' +', '_', value),
        )
    ).lower()


def to_human(value):
    return to_snake(value).replace("_", " ").title()


def to_kebab(value):
    return to_snake(value).replace('_', '-')


def to_screaming_snake(value):
    return to_snake(value).upper()


def to_camel(value):
    first, *rest = to_snake(value).split('_')

    return first + "".join([word.capitalize() for word in rest])


def to_pascal(value):
    return "".join([word.capitalize() for word in to_snake(value).split('_')])


def switcher(k, m):
    if k in m:
        return m[k]

    if 'default' in m:
        return m['default']

    raise ValueError(f'Unknown key for switcher: {k}')


def switcher_fn(k, m):
    f = switcher(k)

    return f()

def strip(v):
    return v.strip()
