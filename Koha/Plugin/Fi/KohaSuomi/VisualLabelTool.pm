package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool;

## It's good practice to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

## We will also need to include any Koha libraries we want to access
use C4::Context;
use utf8;
use JSON;
use File::Slurp;

## Here we set our plugin version
our $VERSION = "1.1.1";

my $lang = C4::Languages::getlanguage() || 'en';
my $name = "";
my $description = "";
if ( $lang eq 'sv-SE' ) {
    $name = "Etikettverktyg";
    $description = "Skapa och skriv ut etiketter. (Lokala databaser)";
} elsif ( $lang eq 'fi-FI' ) {
    $name = "Tarratulostustyökalu";
    $description = "Tee ja tulosta tarroja. (Paikalliskannat)";
} else {
    $name = "Visual Label Tool";
    $description = "Create and print labels.";
}

## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => $name,
    author          => 'Johanna Räisä',
    date_authored   => '2021-02-25',
    date_updated    => "2025-11-06",
    minimum_version => '23.11.00.000',
    maximum_version => undef,
    version         => $VERSION,
    description     => $description,
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

sub intranet_js {
    my ( $self, $args ) = @_;

    my $dir=C4::Context->config('pluginsdir');
    my $plugin_fulldir = $dir . "/Koha/Plugin/Fi/KohaSuomi/VisualLabelTool/";
    my $js = read_file($plugin_fulldir .'script.js');
    
    # my $param_a = $self->retrieve_data('config_param_a');
    
    # # Add REPLACE_BY_CONFIG_PARAM_A to the js script to replace it with the configuration parameter
    # $js = $js =~ s/REPLACE_BY_CONFIG_PARAM_A/$param_a/r;
    
    utf8::decode($js);
    return "<script>$js</script>";
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
    return 1;
}

## This is the 'upgrade' method. It will be triggered when a newer version of a
## plugin is installed over an existing older version of a plugin
sub upgrade {
    my ( $self, $args ) = @_;

    $self->upgradeTables();
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
    my $printedTable = $self->get_qualified_table_name('printed');
    my $printQueueTable = $self->get_qualified_table_name('print_queue');

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
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $dbh->do("CREATE TABLE IF NOT EXISTS `$fieldsTable` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `label_id` int(11) NOT NULL,
        `type` ENUM('label','signum') NOT NULL,
        `name` varchar(150) NOT NULL,
        `top` varchar(10) DEFAULT NULL,
        `left` varchar(10) DEFAULT NULL,
        `right` varchar(10) DEFAULT NULL,
        `bottom` varchar(10) DEFAULT NULL,
        `fontsize` varchar(10) DEFAULT NULL,
        `fontfamily` varchar(50) DEFAULT NULL,
        `fontweight` ENUM('normal','bold') DEFAULT 'normal',
        `whitespace` ENUM('normal','nowrap') DEFAULT 'nowrap',
        `height` varchar(10) DEFAULT NULL,
        `overflow` ENUM('visible','hidden') DEFAULT 'hidden',
        `width` varchar(10) DEFAULT NULL,
        PRIMARY KEY `id` (`id`),
        KEY (`label_id`),
        CONSTRAINT `label_ibfk_1` FOREIGN KEY (`label_id`) REFERENCES `$labelsTable` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $dbh->do("CREATE TABLE IF NOT EXISTS `$printQueueTable` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `borrowernumber` int(11) NOT NULL,
        `itemnumber` int(11) NOT NULL,
        `printed` tinyint(1) NOT NULL DEFAULT 0,
        `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY `id` (`id`),
        KEY (`borrowernumber`),
        CONSTRAINT `koha_plugin_fi_kohasuomi_visuallabeltool_print_queue_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");
}

sub upgradeTables {
    my ( $self ) = @_;

    my $dbh = C4::Context->dbh;

    my $labelsTable = $self->get_qualified_table_name('labels');
    my $fieldsTable = $self->get_qualified_table_name('fields');
    my $printedTable = $self->get_qualified_table_name('printed');
    my $printQueueTable = $self->get_qualified_table_name('print_queue');

    $dbh->do("ALTER TABLE `$fieldsTable` ADD COLUMN IF NOT EXISTS `bottom` varchar(10) DEFAULT NULL;");
    $dbh->do("ALTER TABLE `$fieldsTable` ADD COLUMN IF NOT EXISTS `fontfamily` varchar(50) DEFAULT NULL;");
    $dbh->do("ALTER TABLE `$fieldsTable` ADD COLUMN IF NOT EXISTS `fontweight` ENUM('normal','bold') DEFAULT 'normal';");
    $dbh->do("ALTER TABLE `$fieldsTable` MODIFY `name` varchar(150) NOT NULL;");
    $dbh->do("ALTER TABLE `$fieldsTable` ADD COLUMN IF NOT EXISTS `whitespace` ENUM('normal','nowrap') DEFAULT 'nowrap';");
    $dbh->do("ALTER TABLE `$fieldsTable` ADD COLUMN IF NOT EXISTS `height` varchar(10) DEFAULT NULL;");
    $dbh->do("ALTER TABLE `$fieldsTable` ADD COLUMN IF NOT EXISTS `overflow` ENUM('visible','hidden') DEFAULT 'hidden';");
    $dbh->do("ALTER TABLE `$fieldsTable` ADD COLUMN IF NOT EXISTS `width` varchar(10) DEFAULT NULL;");
}


1;
