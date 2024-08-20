create table orcid_users(
id serial,
name text,
key text,
--user_id int references users,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table ensembl_subdomains(
id serial,
name text,
latest_ensembl_release int,
primary key (id)
);

create table organisms(
id serial,
name text,
short_name text,
go_short_name text,
genrep_key text,
tax_id int,
tag text,
ensembl_subdomain_id int references ensembl_subdomains (id),
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table genes(
id serial,
ensembl_id text,
ncbi_gene_id int,
name text,
biotype text,
chr text,
gene_length int,
sum_exon_length int,
organism_id int references organisms,
alt_names text,
latest_ensembl_release int,
description text,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create index genes_ensembl_id_idx on genes (ensembl_id);
create index genes_name_idx on genes (name);

create table workspaces(
id serial,
key text,
name text,
short_description text,
description text,
contributors text,
disclaimer text,
how_to_contribute text,
user_id int references users,
is_public bool default false,
organism_id int references organisms,
nber_claims int,
nber_articles int,
nber_comments int,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create index workspaces_key_idx on workspaces (key);

create table workspace_orcid_users(
id serial,
workspace_id int references workspaces,
orcid_user_id int references orcid_users,
	      banned bool default false,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table assertion_types(
id serial,
name text,
label text,
badge_tag_classes text default '',
badge_classes text default '',
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table assertions(
id serial,
content text,
article_id int references articles,
assertion_type_id int references assertion_types,
rank int,
assessment_type_id int references assessment_types, -- only for assessment type of assertions
--assessment text,
user_id int references users,
orcid_user_id int references orcid_users,
obsolete bool default false,
all_tags_json text default '[]',
ext text,	      
pmid text,
main_lab text,
large_scale bool,
-- red_by int references users,
-- red_at timestamp.
created_at timestamp,
updated_at timestamp,
--content_modified_at timestamp,
primary key (id)
);

create table assertion_versions(
id serial,
content text,
all_tags_json text default '[]',
assessment_type_id int references assessment_types,
assessment text,
assertion_id int references assertions,
user_id int references users,
orcid_user_id int references orcid_users,
version int default 1,
minor bool default false,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create index assertion_versions_assertion_id_idx on assertion_versions (assertion_id);

create table comment_checks(
id serial,
assertion_id int references assertions,
user_id int references users, -- checked by
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table techniques(
id serial,
label text,
user_id int references users,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

--create table techniques(
--id serial,
--assertion_id int references assertions,
--user_id int references users,
--created_at timestamp,
--updated_at timestamp,
--primary key (id)
--);

create table assertions_techniques(
assertion_id int references assertions,
technique_type_id int references techniques
);

create table rel_types(
id serial,
name text,
subject_type_id int,
user_id int references users,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table rels(
id serial,
subject_id int references assertions,
complement_id int references assertions,
rel_type_id int references rel_types,
subject_rank int,
complement_rank int,
user_id int references users,
orcid_user_id int references orcid_users,
obsolete bool default false,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table journals(
id serial,
name text,
tag text,
impact_factor float,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table articles(
id serial,
key text,
num int,
workspace_id int references workspaces,
authors_txt text,
affs_json text,
author_details_json text,
title text,
journal_id int references journals,
pmid int,
volume text,
issue text,
abstract text,
stats_json text, -- nber_views
year int,
organism_id int references organisms,
published_at timestamp,
user_id int references users,
orcid_user_id int references orcid_users,
created_at timestamp,
updated_at timestamp,
additional_context text,
references_txt text,
assertion_updated_at timestamp,
obsolete bool default false,
large_scale bool default false,
validated_by int references users,
validated_at timestamp,		     
primary key (id)
);

create index articles_key_idx on articles (key);
create index articles_pmid_idx on articles (pmid);

create table additional_files(
id serial,
article_id int references articles,
num int,
ext text,
label text,
description text,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table shares(
id serial,
workspace_id int references workspaces,
user_id int references users, -- can be null,
orcid_user_id int references orcid_users,                                          
email text,
view_perm bool default false,
comment_perm bool default false,
annot_perm bool default false,
share_perm bool default false, --handle permissions (except workspace owner)
edit_perm bool default false,
banned bool default false,
accepted_disclaimer_at timestamp, -- bool default false,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table banned_orcid_users(
 id serial,
 orcid_user_id int references orcid_users,
 workspace_id int references workspaces,
 created_at timestamp,
 updated_at timestamp,
 primary key (id)
);

create table articles_genes(
 article_id int references articles,
 gene_id int references genes
);

create table assertions_genes(
 assertion_id int references assertions,
 gene_id int references genes
);

create table tags(
id serial,
name text,
user_id int references users,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table assertions_tags(
assertion_id int references assertions,
 tag_id int references tags
);

create table assessment_types(
id serial,
name text,
icon_classes text,
rank int,
user_id int references users,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

--create table assessments(
--id serial,
--assertion_id int references assertions,
--assessment_type_id int references assessment_types,
--user_id int references users,
--created_at timestamp,
--updated_at timestamp,
--primary key (id)
--);

--create table comments(
--id serial,
--assertion_id int references assertions,
--content text,
--user_id int references users,
--created_at timestamp,
--updated_at timestamp,
--primary key (id)
--);

create table abuse_report_types(
id serial,
name text,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table abuse_reports(
id serial,
user_id int references users,
orcid_user_id int references orcid_users,
assertion_id int references assertions,
abuse_report_type_id int references abuse_report_types,
message text,
created_at timestamp,
updated_at timestamp,
primary key (id) 
);

create table career_stages(
id serial,
name text,
primary key (id)
);

create table expertise_levels(
id serial,
name text,
primary key (id)
);

create table authors(
id serial,
article_id int reference articles,
name text,
sex int,
career_stage_id int references career_stages,
leading_author bool,
first_author bool,
expertise_level_id int references expertise_levels,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table reason_types(
id serial,
name text,
created_at timestamp,
updated_at timestamp,
primary key (id)
);

create table reasons(
id serial,
assertion_id int references assertions,
reason_type_ids text, -- int references reason_types,
comment text,
rel_id int references rels,
user_id int references users,
created_at timestamp,
updated_at timestamp,
primary key (id)
);
