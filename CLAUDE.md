# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Frontend Development
- `npm run dev` - Start Vite development server with hot reload
- `npm run build` - Build production assets with Vite
- `npm run watch` - Watch for changes and rebuild assets

### Laravel/Statamic Development
- `php artisan serve` - Start Laravel development server
- `php artisan queue:listen --tries=1` - Start queue worker
- `php artisan pail --timeout=0` - Start log viewer
- `composer dev` - Start all services concurrently (server, queue, logs, vite)
- `composer test` - Run PHPUnit tests
- `php artisan test` - Alternative test command

### Statamic Specific
- `php artisan statamic:install` - Install/reinstall Statamic
- `php please` - Statamic CLI tool for various CMS operations
- `php artisan statamic:stache:clear` - Clear Statamic cache (run after blueprint changes)
- `php artisan statamic:stache:refresh` - Clear and rebuild Statamic cache

## Code Architecture

### CMS Structure
This is a **Statamic 5** portfolio website built on **Laravel 12** with **PHP 8.2**. Statamic is a flat-file CMS that stores content in YAML/Markdown files rather than a database.

### Content Organization
- **Collections**: Blog posts, projects, work experience, code snippets, and pages
- **Globals**: Profile information stored in `content/globals/profile.yaml`
- **Navigation**: Main and footer navigation in `content/navigation/`
- **Taxonomies**: Categories, tags, and programming languages for content classification

### Frontend Stack
- **Templating**: Antlers (Statamic's template engine) in `resources/views/*.antlers.html`
- **Styling**: Tailwind CSS 4 with custom styles in `resources/css/site.css`
- **JavaScript**: Alpine.js for interactive components
- **Build Tool**: Vite with Laravel integration

### Key Directories
- `content/` - All CMS content (markdown files, YAML data)
- `resources/views/` - Antlers templates
- `resources/blueprints/` - Content structure definitions
- `config/statamic/` - Statamic-specific configuration
- `storage/framework/cache/data/stache/` - Statamic's file-based cache

### Content Types
1. **Blog** (`content/collections/blog/`) - Technical articles with categories and tags
2. **Projects** (`content/collections/projects/`) - Portfolio projects with featured status
3. **Work Experience** (`content/collections/work_experience/`) - Professional experience entries
4. **Code Snippets** (`content/collections/code_snippets/`) - Categorized by programming language
5. **Pages** (`content/collections/pages/`) - Static pages like About, Contact, Resume

### Configuration Notes
- Git integration is disabled
- REST and GraphQL APIs are disabled
- Static caching is disabled (development mode)
- Local search driver is used
- User management is file-based (not database)

## Statamic Blueprint Configuration

### Blueprint File Structure
Blueprints MUST follow this directory structure:
```
resources/blueprints/collections/
├── {collection_name}/
│   └── {blueprint_name}.yaml
```

**Example:**
- Collection: `projects` → Blueprint: `resources/blueprints/collections/projects/project.yaml`
- Collection: `blog` → Blueprint: `resources/blueprints/collections/blog/article.yaml`

### Blueprint Configuration Chain
1. **Collection Config** (`content/collections/{collection}.yaml`):
   ```yaml
   title: Collection Title
   blueprint: {blueprint_name}  # Must match blueprint filename
   template: {template_name}    # Optional template override
   ```

2. **Entry Files** (`content/collections/{collection}/*.md`):
   ```yaml
   ---
   blueprint: {blueprint_name}  # Must match blueprint filename
   template: {template_name}    # Optional template override
   ---
   ```

3. **Blueprint File** (`resources/blueprints/collections/{collection}/{blueprint_name}.yaml`):
   ```yaml
   title: Blueprint Title
   tabs:
     main:
       display: Main
       sections:
         - fields:
             - handle: field_name
               field:
                 type: field_type
                 display: Field Label
   ```

### Field Types & Best Practices
- **Text fields**: `type: text` for simple text input
- **Select fields**: `type: select` with `options:` for dropdowns
- **Toggle fields**: `type: toggle` for boolean values
- **Lists**: `type: list` for simple arrays
- **Taxonomies**: `type: terms` with `taxonomies: [taxonomy_name]` and `create: true`
- **Assets**: `type: assets` with `container: assets` and `max_files: 1`
- **Markdown**: `type: markdown` for rich content
- **Numbers**: `type: integer` for numeric values

### Taxonomy Management
- Create taxonomy files in `content/taxonomies/{taxonomy_name}.yaml`
- Use `type: terms` field with `taxonomies: [taxonomy_name]`
- Add `create: true` to allow creating terms from entry forms
- Example: Technologies taxonomy for reusable tech tags across projects

### Common Issues & Solutions
- **Only title/content showing**: Blueprint file structure is wrong or blueprint name mismatch
- **FieldtypeNotFoundException**: Field type doesn't exist (e.g., `tags` requires taxonomy setup)
- **Blueprint not loading**: Clear Stache cache with `php artisan statamic:stache:clear`
- **YAML parsing errors**: Check for Windows line endings (`\r\n`) - use Unix line endings (`\n`)
- **Fields not saving**: Blueprint handle must match exactly with entry field names

### Cache Management
- ALWAYS run `php artisan statamic:stache:clear` after blueprint changes
- Blueprint changes won't appear in Control Panel until cache is cleared
- Use `php artisan statamic:stache:refresh` for complete rebuild if issues persist