# GitHub Wiki Guide for Everything App

## What is GitHub Wiki?

GitHub Wiki is a built-in documentation platform that provides:
- **Separate Git Repository**: Version-controlled documentation
- **Better Navigation**: Automatic sidebar and page linking
- **Search Functionality**: Full-text search across all pages
- **Clean URLs**: User-friendly page URLs
- **No PR Required**: Direct editing for documentation

## Wiki Structure vs Repository Docs

### Current Repository Structure
```
docs/
├── architecture/        # Technical documentation
├── stories/            # User stories
├── prd.md             # Product requirements
└── development-status.md
```

### Proposed Wiki Structure
```
wiki/
├── Home.md            # Landing page with navigation
├── _Sidebar.md        # Navigation menu
├── README.md          # Project overview
├── Architecture/      # Technical docs
├── Stories/           # User stories
└── Guides/           # Development guides
```

## Setting Up the Wiki

### Method 1: Manual Setup
1. Go to repository Settings → Features → Enable Wiki
2. Click on "Wiki" tab in repository
3. Create first page (automatically becomes Home)
4. Add pages using "New Page" button

### Method 2: Git Clone and Edit Locally
```bash
# Clone wiki repository
git clone https://github.com/caioniehues/everything-app.wiki.git

# Edit locally with your favorite editor
cd everything-app.wiki
vim Home.md

# Commit and push
git add -A
git commit -m "Update documentation"
git push origin master
```

### Method 3: Automated Sync (Recommended)
Use the provided sync script or GitHub Action:

```bash
# One-time sync
./scripts/sync-wiki.sh

# Automatic sync on push (via GitHub Action)
# Already configured in .github/workflows/wiki-sync.yml
```

## Wiki Features and Syntax

### Page Linking
```markdown
# Internal links
[[Page Name]]                    # Links to Page-Name.md
[[Custom Text|Page Name]]        # Custom link text
[[Epic-1-Authentication#Stories]] # Link to section

# External links
[Repository](https://github.com/caioniehues/everything-app)
```

### Navigation Sidebar (_Sidebar.md)
```markdown
### Navigation

**Getting Started**
- [[Home]]
- [[Setup Guide]]

**Documentation**
- [[Architecture]]
- [[API Reference]]
```

### Special Pages
- **Home.md**: Landing page (required)
- **_Sidebar.md**: Navigation menu (optional)
- **_Footer.md**: Page footer (optional)

## Benefits of Using Wiki for Your Project

### 1. Better Organization
- Hierarchical navigation
- Automatic table of contents
- Cross-page linking
- Search functionality

### 2. Easier Maintenance
- No PR needed for doc updates
- Direct editing in browser
- Version history tracking
- Rollback capability

### 3. Enhanced Readability
- Clean URLs without file extensions
- Automatic formatting
- Syntax highlighting
- Image embedding

### 4. Separate Concerns
- Code in main repo
- Documentation in wiki
- Different access permissions
- Cleaner repository

## Recommended Wiki Structure for Everything App

```
Home.md                          # Main landing page
├── Getting-Started/
│   ├── Prerequisites.md         # System requirements
│   ├── Installation.md          # Setup instructions
│   └── Quick-Start.md          # Fast track guide
├── Architecture/
│   ├── Overview.md             # System architecture
│   ├── Backend.md              # Spring Boot details
│   ├── Frontend.md             # Flutter details
│   └── Database.md             # PostgreSQL schema
├── Stories/
│   ├── Epic-Summary.md         # All epics overview
│   ├── Epic-1-Auth/           # Authentication stories
│   ├── Epic-2-Accounts/       # Account stories
│   └── Sprint-Planning.md     # Current sprint
├── Development/
│   ├── BMAD-Workflow.md       # Development process
│   ├── TDD-Guide.md           # Testing approach
│   ├── Coding-Standards.md    # Code conventions
│   └── GitHub-Actions.md      # CI/CD documentation
└── API/
    ├── Authentication.md       # Auth endpoints
    ├── Accounts.md            # Account endpoints
    └── Transactions.md        # Transaction endpoints
```

## Automation Options

### 1. GitHub Action (Already Created)
The `wiki-sync.yml` workflow automatically:
- Syncs on push to main branch
- Converts markdown files
- Creates navigation structure
- Updates timestamps

### 2. Manual Script (Also Created)
The `sync-wiki.sh` script:
- Can be run locally
- Provides more control
- Useful for testing

### 3. CI/CD Integration
```yaml
# In your CI/CD pipeline
- name: Sync Wiki
  run: ./scripts/sync-wiki.sh
```

## Wiki Best Practices

### Do's
✅ Keep pages focused and concise
✅ Use descriptive page names
✅ Create a clear navigation structure
✅ Include a search-friendly home page
✅ Regular updates and maintenance
✅ Use images and diagrams
✅ Cross-link related pages

### Don'ts
❌ Don't duplicate code in wiki
❌ Don't store sensitive information
❌ Don't create overly nested structures
❌ Don't forget to update navigation
❌ Don't use spaces in filenames

## Migration Strategy

### Phase 1: Initial Setup
1. Enable wiki in repository
2. Run sync script to populate
3. Review and adjust structure
4. Set up automation

### Phase 2: Organization
1. Create logical sections
2. Add navigation sidebar
3. Create index pages
4. Add search keywords

### Phase 3: Maintenance
1. Regular sync from main docs
2. Manual enhancements
3. User feedback integration
4. Continuous improvement

## Access Control

### Wiki Permissions
- **Public Repos**: Wiki editable by collaborators
- **Private Repos**: Same access as repository
- **Restrict Editing**: Settings → Manage Access

### Recommended Settings
- Read: Everyone (for open source)
- Write: Collaborators only
- Admin: Repository owners

## Viewing the Wiki

### Web Interface
```
https://github.com/caioniehues/everything-app/wiki
```

### Local Clone
```bash
git clone https://github.com/caioniehues/everything-app.wiki.git
```

### API Access
```bash
# Get wiki pages via API
curl -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/caioniehues/everything-app/pages
```

## Comparison with Repository Docs

| Feature | Repository `/docs` | GitHub Wiki |
|---------|-------------------|-------------|
| Version Control | With code | Separate repo |
| PR Required | Yes | No |
| Search | GitHub search | Wiki search |
| Navigation | Manual | Automatic |
| Access Control | Same as repo | Can be different |
| URL Structure | Path-based | Page-based |
| Editing | IDE/Editor | Web or local |
| Best For | API docs, README | Guides, tutorials |

## Next Steps

1. **Enable Wiki**: Go to Settings → Features → Wiki
2. **Initial Sync**: Run `./scripts/sync-wiki.sh`
3. **Review Structure**: Check generated pages
4. **Customize**: Add custom pages and navigation
5. **Automate**: Merge PR with wiki-sync.yml
6. **Maintain**: Regular updates and improvements

## Conclusion

GitHub Wiki provides an excellent platform for your comprehensive documentation. With the automation tools provided, you can maintain documentation in both the repository (for version control with code) and the wiki (for better navigation and accessibility).

The hybrid approach allows:
- Technical specs stay with code
- User guides in wiki
- Automatic synchronization
- Best of both worlds

---
*Last Updated: 21/09/2025 02:00:00*