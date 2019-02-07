export default function getMockProjects(projectCount = 1) {
  const mockProjects = [];

  for (let i = 1; i <= projectCount; i += 1) {
    mockProjects.push({
      id: i,
      name: `mock-project-${i}`,
      name_with_namespace: `mock-namespace-${i} / mock-project-${i}`,
      avatar_url: `https://example.com/avatar-url-${i}`,
      web_url: `https://example.com/web-url-${i}`,
    });
  }

  return mockProjects;
}
