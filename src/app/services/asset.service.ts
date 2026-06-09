import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";

export interface AssetDto {
  id: string;
  tag?: string;
  name: string;
  category?: string;
  location?: string;
  status?: string;
  notes?: string;
}

@Injectable({ providedIn: "root" })
export class AssetService {
  private readonly base = "/api/assets";

  constructor(private readonly http: HttpClient) {}

  list(params?: any): Observable<AssetDto[]> {
    return this.http.get<AssetDto[]>(this.base, { params });
  }

  get(id: string): Observable<AssetDto> {
    return this.http.get<AssetDto>(`${this.base}/${id}`);
  }

  create(payload: Partial<AssetDto>) {
    return this.http.post<AssetDto>(this.base, payload);
  }

  update(id: string, payload: Partial<AssetDto>) {
    return this.http.put<AssetDto>(`${this.base}/${id}`, payload);
  }

  delete(id: string) {
    return this.http.delete(`${this.base}/${id}`);
  }
}
