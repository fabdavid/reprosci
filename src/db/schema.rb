# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200422144805) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", id: :serial, force: :cascade do |t|
    t.text "authors"
    t.text "title"
    t.integer "journal_id"
    t.integer "pmid"
    t.text "volume"
    t.text "issue"
    t.text "abstract"
    t.integer "year"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "assertion_updated_at"
    t.text "key"
    t.integer "workspace_id"
    t.integer "user_id"
    t.index ["key"], name: "articles_key_idx"
    t.index ["pmid"], name: "articles_pmid_idx"
  end

  create_table "articles_genes", id: false, force: :cascade do |t|
    t.integer "article_id"
    t.integer "gene_id"
  end

  create_table "assertion_types", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assertion_versions", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "assertion_id"
    t.integer "user_id"
    t.integer "version", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "minor", default: false
    t.index ["assertion_id"], name: "assertion_versions_assertion_id_idx"
  end

  create_table "assertions", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "article_id"
    t.integer "assertion_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank"
    t.boolean "obsolete", default: false
  end

  create_table "assertions_technique_types", id: false, force: :cascade do |t|
    t.integer "assertion_id"
    t.integer "technique_type_id"
  end

  create_table "assertions_techniques", id: false, force: :cascade do |t|
    t.integer "assertion_id"
    t.integer "technique_type_id"
  end

  create_table "claim_types", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "claims", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "claim_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "article_id"
  end

  create_table "ensembl_subdomains", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "latest_ensembl_release"
  end

  create_table "genes", id: :serial, force: :cascade do |t|
    t.text "ensembl_id"
    t.integer "ncbi_gene_id"
    t.text "name"
    t.text "biotype"
    t.text "chr"
    t.integer "gene_length"
    t.integer "sum_exon_length"
    t.integer "organism_id"
    t.text "alt_names"
    t.integer "latest_ensembl_release"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ensembl_id"], name: "genes_ensembl_id_idx"
    t.index ["name"], name: "genes_name_idx"
  end

  create_table "journals", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "tag"
  end

  create_table "organisms", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "short_name"
    t.text "go_short_name"
    t.text "genrep_key"
    t.integer "tax_id"
    t.text "tag"
    t.integer "ensembl_subdomain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rel_types", id: :serial, force: :cascade do |t|
    t.text "name"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rels", id: :serial, force: :cascade do |t|
    t.integer "subject_id"
    t.integer "complement_id"
    t.integer "rel_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "subject_rank"
    t.integer "complement_rank"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "shares", id: :serial, force: :cascade do |t|
    t.integer "workspace_id"
    t.integer "user_id"
    t.text "email"
    t.boolean "view_perm"
    t.boolean "comment_perm"
    t.boolean "annot_perm"
    t.boolean "share_perm"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "edit_perm"
  end

  create_table "technique_types", id: :serial, force: :cascade do |t|
    t.text "label"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "techniques", id: :serial, force: :cascade do |t|
    t.text "label"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "username"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "workspaces", id: :serial, force: :cascade do |t|
    t.text "key"
    t.text "name"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_public", default: false
  end

  add_foreign_key "articles", "journals", name: "articles_journal_id_fkey"
  add_foreign_key "articles", "users", name: "articles_user_id_fkey"
  add_foreign_key "articles", "workspaces", name: "articles_workspace_id_fkey"
  add_foreign_key "articles_genes", "articles", name: "articles_genes_article_id_fkey"
  add_foreign_key "articles_genes", "genes", name: "articles_genes_gene_id_fkey"
  add_foreign_key "assertion_versions", "assertions", name: "assertion_versions_assertion_id_fkey"
  add_foreign_key "assertion_versions", "users", name: "assertion_versions_user_id_fkey"
  add_foreign_key "assertions", "articles", name: "assertions_article_id_fkey"
  add_foreign_key "assertions", "assertion_types", name: "assertions_assertion_type_id_fkey"
  add_foreign_key "assertions", "users", name: "assertions_user_id_fkey"
  add_foreign_key "assertions_technique_types", "assertions", name: "assertions_technique_types_assertion_id_fkey"
  add_foreign_key "assertions_technique_types", "technique_types", name: "assertions_technique_types_technique_type_id_fkey"
  add_foreign_key "assertions_techniques", "assertions", name: "assertions_techniques_assertion_id_fkey"
  add_foreign_key "assertions_techniques", "techniques", column: "technique_type_id", name: "assertions_techniques_technique_type_id_fkey"
  add_foreign_key "claims", "articles", name: "claims_article_id_fkey"
  add_foreign_key "claims", "claim_types", name: "claims_claim_type_id_fkey"
  add_foreign_key "genes", "organisms", name: "genes_organism_id_fkey"
  add_foreign_key "organisms", "ensembl_subdomains", name: "organisms_ensembl_subdomain_id_fkey"
  add_foreign_key "rel_types", "users", name: "rel_types_user_id_fkey"
  add_foreign_key "rels", "assertions", column: "complement_id", name: "rels_complement_assertion_id_fkey"
  add_foreign_key "rels", "assertions", column: "subject_id", name: "rels_subject_assertion_id_fkey"
  add_foreign_key "rels", "rel_types", name: "rels_rel_type_id_fkey"
  add_foreign_key "shares", "users", name: "shares_user_id_fkey"
  add_foreign_key "shares", "workspaces", name: "shares_workspace_id_fkey"
  add_foreign_key "technique_types", "users", name: "technique_types_user_id_fkey"
  add_foreign_key "techniques", "users", name: "techniques_user_id_fkey"
  add_foreign_key "workspaces", "users", name: "workspaces_user_id_fkey"
end
