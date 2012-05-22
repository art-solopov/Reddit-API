use strict;
use warnings;
use Carp;
use JSON       qw//;
use File::Temp qw/tempfile/;
use Reddit::Client;
use Test::More tests => 13;

my ($fh, $filename) = tempfile();
my $reddit = Reddit::Client->new(session_file => $filename);


ok(Reddit::Client::subreddit('/r/foo')  eq 'foo', 'subreddit');
ok(Reddit::Client::subreddit('/foo')    eq 'foo', 'subreddit');
ok(Reddit::Client::subreddit('/r/foo/') eq 'foo', 'subreddit');
ok(Reddit::Client::subreddit('/')       eq '',    'subreddit');
ok(!defined Reddit::Client::subreddit('foo/bar'), 'subreddit');


eval{ $reddit->require_login };
ok($@, 'require_login');
ok(!$reddit->is_logged_in, 'is_logged_in');


$reddit->{modhash} = '.', $reddit->{cookie} = '.';
ok($reddit->is_logged_in, 'is_logged_in');


ok($reddit->save_session, 'save_session');
my $session_data = do { local $/; <$fh> };
my $session = JSON::from_json($session_data);
ok($session->{modhash} eq '.', 'save_session');
ok($session->{cookie}  eq '.', 'save_session');


$reddit->{modhash} = undef, $reddit->{cookie} = '';
$reddit->load_session;
ok($session->{modhash} eq '.', 'load_session');
ok($session->{cookie}  eq '.', 'load_session');

1;