# MyMCP API Documentation

The MyMCP API provides access to MCP (Model Context Protocol) server data enriched with GitHub metadata. Data is synced daily from the [official MCP Registry](https://registry.modelcontextprotocol.io).

## Base URL

```
https://www.josh.ing/api/mymcp
```

---

## Endpoints

### GET `/servers`

Returns a paginated list of MCP servers with optional filtering and sorting.

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `search` | string | - | Text search on name, title, and description |
| `sort` | string | `stars` | Sort order: `stars`, `forks`, `recent`, `name`, `updated` |
| `limit` | number | `50` | Results per page (max: 100) |
| `offset` | number | `0` | Pagination offset |
| `latest_only` | boolean | `true` | Only show latest version of each server |
| `language` | string | - | Filter by GitHub primary language (e.g., `TypeScript`) |
| `min_stars` | number | - | Minimum GitHub stars |

#### Example Requests

```bash
# Get top servers by GitHub stars
curl "https://www.josh.ing/api/mymcp/servers?sort=stars&limit=10"

# Search for filesystem-related servers
curl "https://www.josh.ing/api/mymcp/servers?search=filesystem"

# Get TypeScript servers with 100+ stars
curl "https://www.josh.ing/api/mymcp/servers?language=TypeScript&min_stars=100"

# Get all versions of servers (not just latest)
curl "https://www.josh.ing/api/mymcp/servers?latest_only=false"

# Paginate through results
curl "https://www.josh.ing/api/mymcp/servers?limit=50&offset=50"
```

#### Response Format

```json
{
  "servers": [
    {
      "name": "io.github.anthropics/mcp-server-fetch",
      "title": "Fetch",
      "description": "A server for fetching web content and converting it to markdown",
      "version": "0.6.2",
      "repository_url": "https://github.com/modelcontextprotocol/servers",
      "website_url": null,
      "packages": [
        {
          "registry_type": "npm",
          "name": "@anthropic-ai/mcp-server-fetch",
          "version": "0.6.2"
        }
      ],
      "remotes": null,
      "is_latest": true,
      "registry_status": "active",
      "registry_published_at": "2025-01-15T10:30:00Z",
      "registry_updated_at": "2025-12-18T14:22:00Z",
      "github": {
        "owner": "modelcontextprotocol",
        "repo": "servers",
        "stars": 25271,
        "forks": 1842,
        "open_issues": 156,
        "language": "TypeScript",
        "topics": ["mcp", "model-context-protocol", "ai"],
        "license": "MIT",
        "last_commit_at": "2025-12-19T02:15:00Z",
        "archived": false
      },
      "synced_at": {
        "registry": "2025-12-19T02:31:45Z",
        "github": "2025-12-19T02:32:10Z"
      }
    }
  ],
  "pagination": {
    "total": 1117,
    "limit": 50,
    "offset": 0,
    "has_more": true
  },
  "filters": {
    "search": null,
    "sort": "stars",
    "latest_only": true,
    "language": null,
    "min_stars": null
  }
}
```

#### Server Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique server identifier (e.g., `io.github.owner/name`) |
| `title` | string | Display name |
| `description` | string | Server description |
| `version` | string | Semantic version |
| `repository_url` | string | Source code repository URL |
| `website_url` | string | Documentation or homepage URL |
| `packages` | array | Distribution packages (npm, PyPI, Docker) |
| `remotes` | array | Remote server endpoints (HTTP, SSE) |
| `is_latest` | boolean | Whether this is the latest version |
| `registry_status` | string | Status in MCP registry |
| `registry_published_at` | string | First published timestamp |
| `registry_updated_at` | string | Last registry update |
| `github` | object | GitHub repository metadata (null if no GitHub repo) |
| `synced_at` | object | Last sync timestamps |

#### GitHub Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `owner` | string | GitHub repository owner |
| `repo` | string | GitHub repository name |
| `stars` | number | Star count |
| `forks` | number | Fork count |
| `open_issues` | number | Open issue count |
| `language` | string | Primary programming language |
| `topics` | array | Repository topics/tags |
| `license` | string | License SPDX identifier |
| `last_commit_at` | string | Last commit timestamp |
| `archived` | boolean | Whether repo is archived |

---

## Data Freshness

- **Sync Schedule**: Daily at 6:00 AM UTC
- **Data Source**: [Official MCP Registry](https://registry.modelcontextprotocol.io)
- **GitHub Metadata**: Fetched via GitHub API with rate limiting

---

## Statistics

As of the last sync:

| Metric | Count |
|--------|-------|
| Total server entries (all versions) | ~2,800 |
| Unique servers (latest only) | ~1,100 |
| Servers with GitHub repos | ~790 |

---

## Rate Limiting

The API does not currently enforce rate limits, but please be respectful:
- Cache responses where possible
- Use pagination instead of fetching all data at once
- Consider the `revalidate: 60` cache (responses are cached for 1 minute)

---

## Error Responses

```json
{
  "error": "Failed to fetch servers"
}
```

| Status | Description |
|--------|-------------|
| `200` | Success |
| `500` | Internal server error |

---

## Usage Examples

### JavaScript/TypeScript

```typescript
async function getMCPServers(options = {}) {
  const params = new URLSearchParams({
    sort: options.sort || 'stars',
    limit: String(options.limit || 50),
    ...(options.search && { search: options.search }),
    ...(options.language && { language: options.language }),
    ...(options.minStars && { min_stars: String(options.minStars) }),
  });

  const response = await fetch(
    `https://www.josh.ing/api/mymcp/servers?${params}`
  );
  return response.json();
}

// Get top 10 TypeScript MCP servers
const result = await getMCPServers({
  language: 'TypeScript',
  limit: 10,
  sort: 'stars'
});

console.log(`Found ${result.pagination.total} servers`);
result.servers.forEach(s => {
  console.log(`${s.name}: ${s.github?.stars || 0} stars`);
});
```

### Swift

```swift
struct MCPServer: Codable {
    let name: String
    let title: String?
    let description: String?
    let version: String
    let github: GitHubInfo?

    struct GitHubInfo: Codable {
        let stars: Int?
        let language: String?
    }
}

struct MCPResponse: Codable {
    let servers: [MCPServer]
    let pagination: Pagination

    struct Pagination: Codable {
        let total: Int
        let hasMore: Bool

        enum CodingKeys: String, CodingKey {
            case total
            case hasMore = "has_more"
        }
    }
}

func fetchMCPServers() async throws -> MCPResponse {
    let url = URL(string: "https://www.josh.ing/api/mymcp/servers?sort=stars&limit=50")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(MCPResponse.self, from: data)
}
```

---

## Contributing

This API is part of the [MyMCP](https://github.com/jshchnz/MyMCP) project. Issues and contributions welcome!
