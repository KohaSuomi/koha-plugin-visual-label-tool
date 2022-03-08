package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool;

## It's good practice to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

## We will also need to include any Koha libraries we want to access
use C4::Context;
use utf8;
use JSON;

## Here we set our plugin version
our $VERSION = "1.0.0";

## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'Visual label tool',
    author          => 'Johanna Räisä',
    date_authored   => '2021-02-25',
    date_updated    => "2021-02-25",
    minimum_version => '21.11.00.000',
    maximum_version => undef,
    version         => $VERSION,
    description     => 'Create printing labels with drag and drop tool and print them',
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

## The existance of a 'tool' subroutine means the plugin is capable
## of running a tool. The difference between a tool and a report is
## primarily semantic, but in general any plugin that modifies the
## Koha database should be considered a tool

sub tool {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};
    my $template = $self->get_template({ file => 'tool.tt' });
    print $cgi->header(-charset    => 'utf-8');
    print $template->output();
}

## If your tool is complicated enough to needs it's own setting/configuration
## you will want to add a 'configure' method to your plugin like so.
## Here I am throwing all the logic into the 'configure' method, but it could
## be split up like the 'report' method is.
sub configure {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};
    my $template = $self->get_template({ file => 'config.tt' });
    print $cgi->header(-charset    => 'utf-8');
    print $template->output();
}

## This is the 'install' method. Any database tables or other setup that should
## be done when the plugin if first installed should be executed in this method.
## The installation method should always return true if the installation succeeded
## or false if it failed.
sub install() {
    my ( $self, $args ) = @_;

    $self->createTables();
}

## This is the 'upgrade' method. It will be triggered when a newer version of a
## plugin is installed over an existing older version of a plugin
sub upgrade {
    my ( $self, $args ) = @_;

    return 1;
}

## This method will be run just before the plugin files are deleted
## when a plugin is uninstalled. It is good practice to clean up
## after ourselves!
sub uninstall() {
    my ( $self, $args ) = @_;

    return 1;

    #my $table = $self->get_qualified_table_name('label_sheets');

    #return C4::Context->dbh->do("DROP TABLE IF EXISTS $table");
}

sub api_routes {
    my ( $self, $args ) = @_;

    my $spec_str = $self->mbf_read('openapi.json');
    my $spec     = decode_json($spec_str);

    return $spec;
}

sub api_namespace {
    my ( $self ) = @_;
    
    return 'kohasuomi';
}

sub createTables {
    my ( $self ) = @_;

    my $dbh = C4::Context->dbh;

    my $labelsTable = $self->get_qualified_table_name('labels');
    my $fieldsTable = $self->get_qualified_table_name('fields');

    $dbh->do("CREATE TABLE IF NOT EXISTS `$labelsTable` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `name` varchar(100) NOT NULL,
        `type` ENUM('14','12','10','roll','signum') NOT NULL,
        `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        `labelcount` int(11) DEFAULT NULL,
        `width` varchar(10) DEFAULT NULL,
        `height` varchar(10) DEFAULT NULL,
        `top` varchar(10) DEFAULT NULL,
        `left` varchar(10) DEFAULT NULL,
        `right` varchar(10) DEFAULT NULL,
        `bottom` varchar(10) DEFAULT NULL,
        `signum_width` varchar(10) DEFAULT NULL,
        `signum_height` varchar(10) DEFAULT NULL,
        `signum_top` varchar(10) DEFAULT NULL,
        `signum_left` varchar(10) DEFAULT NULL,
        `signum_right` varchar(10) DEFAULT NULL,
        `signum_bottom` varchar(10) DEFAULT NULL,
        PRIMARY KEY `id` (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    ");

    $dbh->do("CREATE TABLE IF NOT EXISTS `$fieldsTable` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `label_id` int(11) NOT NULL,
        `type` ENUM('label','signum') NOT NULL,
        `name` varchar(100) NOT NULL,
        `top` varchar(10) DEFAULT NULL,
        `left` varchar(10) DEFAULT NULL,
        `fontsize` varchar(10) DEFAULT NULL,
        PRIMARY KEY `id` (`id`),
        KEY (`label_id`),
        CONSTRAINT `label_ibfk_1` FOREIGN KEY (`label_id`) REFERENCES `$labelsTable` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    ");
}

1;
